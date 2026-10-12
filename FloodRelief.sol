// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title FloodRelief - transparent donation pool and verified aid release (FloodGuard prototype)
/// @notice PROTOTYPE for a proposal. Not audited. Use on a testnet only.
/// @dev Roles: admin (deploys, manages roles), oracle (FloodGuard server anchoring alerts),
///      verifier (ward officials / rescue teams), ngo (whitelisted relief organisations).
///      Household identity is stored only as a hash (bytes32) - no personal data on-chain.
contract FloodRelief {
    // ---------------------------------------------------------------- roles
    address public admin;
    mapping(address => bool) public isOracle;
    mapping(address => bool) public isVerifier;
    mapping(address => bool) public isNGO;

    // ---------------------------------------------------------------- data
    struct Disaster {
        string name;           // e.g. "Bhote Koshi flash flood 2026"
        bool active;
        uint256 pool;          // total donated
        uint256 reserved;      // locked for submitted aid claims
        uint256 paidOut;       // released to NGOs after confirmed receipt
        uint256 maxAidPerHousehold;
    }

    struct Household {
        bool registered;
        bool evacuated;
        bool claimed;          // one aid claim per household per disaster (prevents duplication)
        bool received;
        address ngo;
        uint256 amount;
    }

    uint256 public disasterCount;
    mapping(uint256 => Disaster) public disasters;
    mapping(uint256 => mapping(bytes32 => Household)) public households;
    mapping(uint256 => mapping(address => uint256)) public donations; // disasterId => donor => amount

    bool private _locked;

    // ---------------------------------------------------------------- events (the public audit trail)
    event DisasterCreated(uint256 indexed id, string name, uint256 maxAidPerHousehold);
    event AlertAnchored(uint256 indexed disasterId, bytes32 alertHash, uint256 timestamp);
    event Donated(uint256 indexed disasterId, address indexed donor, uint256 amount);
    event HouseholdRegistered(uint256 indexed disasterId, bytes32 indexed householdHash, address verifier);
    event EvacuationConfirmed(uint256 indexed disasterId, bytes32 indexed householdHash, address verifier);
    event AidClaimSubmitted(uint256 indexed disasterId, bytes32 indexed householdHash, address indexed ngo, uint256 amount);
    event ReceiptConfirmed(uint256 indexed disasterId, bytes32 indexed householdHash, address ngo, uint256 amount);

    // ---------------------------------------------------------------- modifiers
    modifier onlyAdmin() { require(msg.sender == admin, "not admin"); _; }
    modifier onlyOracle() { require(isOracle[msg.sender], "not oracle"); _; }
    modifier onlyVerifier() { require(isVerifier[msg.sender], "not verifier"); _; }
    modifier onlyNGO() { require(isNGO[msg.sender], "not ngo"); _; }
    modifier nonReentrant() { require(!_locked, "reentrant"); _locked = true; _; _locked = false; }

    constructor() { admin = msg.sender; }

    // ---------------------------------------------------------------- admin
    function setOracle(address a, bool ok) external onlyAdmin { isOracle[a] = ok; }
    function setVerifier(address a, bool ok) external onlyAdmin { isVerifier[a] = ok; }
    function setNGO(address a, bool ok) external onlyAdmin { isNGO[a] = ok; }

    function createDisaster(string calldata name, uint256 maxAidPerHousehold) external onlyAdmin returns (uint256 id) {
        require(maxAidPerHousehold > 0, "max aid is zero");
        id = ++disasterCount;
        disasters[id] = Disaster(name, true, 0, 0, 0, maxAidPerHousehold);
        emit DisasterCreated(id, name, maxAidPerHousehold);
    }

    function closeDisaster(uint256 id) external onlyAdmin { disasters[id].active = false; }

    // ---------------------------------------------------------------- 1. early-warning anchor
    /// @notice FloodGuard server anchors the hash of an alert record so it can't be edited later.
    function anchorAlert(uint256 disasterId, bytes32 alertHash) external onlyOracle {
        emit AlertAnchored(disasterId, alertHash, block.timestamp);
    }

    // ---------------------------------------------------------------- 2. donations
    function donate(uint256 disasterId) external payable {
        Disaster storage d = disasters[disasterId];
        require(d.active, "disaster not active");
        require(msg.value > 0, "no value");
        d.pool += msg.value;
        donations[disasterId][msg.sender] += msg.value;
        emit Donated(disasterId, msg.sender, msg.value);
    }

    // ---------------------------------------------------------------- 3. verified registry
    /// @param householdHash keccak256(salted national ID / ward record). No personal data on-chain.
    function registerHousehold(uint256 disasterId, bytes32 householdHash) external onlyVerifier {
        require(disasters[disasterId].active, "disaster not active");
        Household storage h = households[disasterId][householdHash];
        require(!h.registered, "already registered"); // no double counting
        h.registered = true;
        emit HouseholdRegistered(disasterId, householdHash, msg.sender);
    }

    function confirmEvacuation(uint256 disasterId, bytes32 householdHash) external onlyVerifier {
        Household storage h = households[disasterId][householdHash];
        require(h.registered, "unknown household");
        require(!h.evacuated, "already confirmed");
        h.evacuated = true;
        emit EvacuationConfirmed(disasterId, householdHash, msg.sender);
    }

    // ---------------------------------------------------------------- 4. aid claim -> receipt -> payout
    /// @notice NGO asks for funds to serve one verified, evacuated household. Funds are reserved, not yet paid.
    function submitAidClaim(uint256 disasterId, bytes32 householdHash, uint256 amount) external onlyNGO {
        Disaster storage d = disasters[disasterId];
        Household storage h = households[disasterId][householdHash];
        require(d.active, "disaster not active");
        require(h.registered && h.evacuated, "household not verified");
        require(!h.claimed, "already claimed"); // no duplicate aid
        require(amount > 0 && amount <= d.maxAidPerHousehold, "amount out of range");
        require(d.pool - d.reserved - d.paidOut >= amount, "insufficient pool");
        h.claimed = true;
        h.ngo = msg.sender;
        h.amount = amount;
        d.reserved += amount;
        emit AidClaimSubmitted(disasterId, householdHash, msg.sender, amount);
    }

    /// @notice Verifier witnesses delivery (future: household signature / SMS OTP). Releases funds to the NGO.
    function confirmReceipt(uint256 disasterId, bytes32 householdHash) external onlyVerifier nonReentrant {
        Disaster storage d = disasters[disasterId];
        Household storage h = households[disasterId][householdHash];
        require(h.claimed && !h.received, "nothing to confirm");
        h.received = true;
        d.reserved -= h.amount;
        d.paidOut += h.amount;
        (bool ok, ) = payable(h.ngo).call{value: h.amount}("");
        require(ok, "payout failed");
        emit ReceiptConfirmed(disasterId, householdHash, h.ngo, h.amount);
    }

    // ---------------------------------------------------------------- views
    function available(uint256 disasterId) external view returns (uint256) {
        Disaster storage d = disasters[disasterId];
        return d.pool - d.reserved - d.paidOut;
    }
}
