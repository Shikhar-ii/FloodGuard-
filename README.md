# FloodGuard: Blockchain Early Warning & Relief

> **Blockchain-Based Flood Early Warning and Transparent Disaster Relief System for Nepal**

![FloodGuard architecture](docs/architecture.png)

*Submission for the Blockchain Breakthroughs for a Better World challenge (HeroX / Coinbase). This repository contains an initial, working prototype: a Solidity smart contract and a Python risk engine. It is a proof of concept, **not audited**, and intended for testnet use only.*

---

## Proposal answers

### Title (max 50 words)
Blockchain-Based Flood Early Warning and Transparent Disaster Relief System for Nepal

### Title (50 characters or fewer)
FloodGuard: Blockchain Early Warning & Relief

### Short description (140 characters or fewer)
After losing loved ones in Nepal's floods, I'm building FloodGuard: AI flood alerts plus blockchain-verified, transparent relief.

### Image
`docs/architecture.png` (1300 x 732 px)

### How did you hear about this challenge?
HeroX (Coinbase "Blockchain Breakthroughs for a Better World").

### What problem do you want to solve using blockchain, crypto, or decentralized finance?
*Who is affected by this problem, and why does it matter?*

Flood-prone communities in Nepal and the Himalayan region are hit by sudden floods with little warning, and then by slow, opaque relief. In the August 2026 Bhote Koshi flash flood, Nepal's disaster authority (NDRRMA) reported 1,342 deaths and almost 4,900 people missing or out of contact by 6 September. The IOM estimated 84,270 people affected across 17 municipalities in six districts.

After a disaster, trust breaks down. Donors cannot see where money goes. Affected people can be missed or counted twice. Aid can be delayed by paperwork or diverted by fraud. Early warnings need to be fast, but relief needs to be verifiable. Blockchain fits the second problem: many parties (donors, government, NGOs, communities) who do not fully trust each other must share one record.

### What is your idea?
*Briefly describe how blockchain, tokenization, or decentralized ownership could help solve this problem.*

FloodGuard uses blockchain only where trust and verification matter: after the warning, during relief.

Sensors, weather data and satellite imagery feed an AI risk engine that sends early SMS alerts to at-risk communities. These alerts are sent without blockchain, because speed matters most. Alert, evacuation and household records are then written to a shared blockchain ledger that ward officials, rescue teams, NGOs and donors can all see. Donations are held in smart contracts and released only when evacuation and aid delivery are verified, and each affected household confirms receipt on-chain. Each household gets a digital ID (stored as a hash, with no personal data on-chain), so no one is counted twice or missed. This reduces fraud, duplication and delays, and lets donors see exactly where their money goes.

### What makes your idea innovative or different?
*What makes this approach stand out from existing solutions?*

FloodGuard's innovation lies in using blockchain to make disaster relief transparent, traceable, and accountable. Unlike traditional relief systems, where donors may struggle to verify how funds are spent, FloodGuard records donations, fund transfers, evacuation confirmations, and aid delivery on a tamper-resistant ledger. Smart contracts automate fund distribution to verified NGOs and suppliers when predefined conditions are met, reducing delays and opportunities for fraud. Donors can trace their contributions, while ward officials, rescue teams, and affected households can verify relief activities and confirm aid receipt. By creating a shared, verifiable record accessible to authorized participants, FloodGuard reduces dependence on a single authority and builds trust among donors, governments, and communities. Its key innovation is transforming disaster relief from a system that relies heavily on trust into one where transactions and aid delivery can be independently verified.

### Who would benefit from your solution, and how?
*What positive impact could your idea have?*

Starting in Nepal: I want to implement FloodGuard in flood-prone communities. Villagers get earlier warnings on ordinary phones. Households that are affected get faster, fairer aid because they are verified once and cannot be missed or duplicated. Donors get proof of where their money went. NGOs and local authorities get a shared record that cuts paperwork and disputes.

The target is to reach 1 million people across the Great Himalayan region. Globally, around 1.47 billion people face significant flood risk, with average annual flood losses of about $388 billion, so the same model can be adapted to other flood-prone countries.

### Why do you want to work on this idea?
*What inspired you to tackle this problem?*

I lost people close to me in Nepal's floods. I cannot bring them back, but I can work so that the next community gets a warning in time, and so that help reaches the people who need it without delay or waste.

### Optional: pitch deck (PDF, max 10 slides)
*(add file)*

### Optional: link to supporting documentation
*(add repository link)*

### Optional: video URL (YouTube or Vimeo, max 2 minutes)
*(add link)*

---

## How it works

```
Sensors + Weather + Satellite -> Risk Prediction -> Local Alerts -> Verified Evacuation -> Transparent Aid Tracking
        (off-chain, fast)                                         (on-chain, verifiable)
```

| Step | Component | On-chain? |
|---|---|---|
| Sense river level, rain, soil, upstream hazards | `risk_engine/` | No (speed matters) |
| Score risk and choose alert level | `risk_engine/risk_engine.py` | No |
| Send SMS in English and Nepali | `send_sms()` stub | No |
| Anchor a hash of every alert | `anchorAlert()` | **Yes** (tamper-proof record) |
| Register households and confirm evacuation | `registerHousehold()`, `confirmEvacuation()` | **Yes** |
| Donate to a disaster pool | `donate()` | **Yes** |
| NGO claims aid for a verified household | `submitAidClaim()` | **Yes** |
| Receipt confirmed, funds released | `confirmReceipt()` | **Yes** |

### Roles in the smart contract
- **Admin:** deploys the contract, creates disasters, assigns roles.
- **Oracle:** the FloodGuard server, which can anchor alert hashes.
- **Verifier:** ward officials and rescue teams, who register households, confirm evacuation and confirm receipt.
- **NGO:** whitelisted relief organisations, who submit aid claims and receive payouts.
- **Donor:** anyone, who can donate to an active disaster pool.

### Built-in safeguards
- One registration per household per disaster, so no double counting.
- One aid claim per household per disaster, so no duplicate aid.
- Aid can only be claimed for households that are registered and evacuated.
- A per-household cap on aid, and funds are reserved before payout.
- Funds are paid to the NGO only after a verifier confirms receipt.
- Households appear only as hashes, so no personal data is on-chain.

---

## Repository structure

```
floodguard/
├── README.md
├── docs/architecture.png          # system diagram
├── contracts/FloodRelief.sol      # donation pool + verified aid release
└── risk_engine/risk_engine.py     # rule-based risk scoring + alert + hash anchoring
```

## Quick start

**1. Risk engine** (Python 3.8+, no dependencies)

```bash
python risk_engine/risk_engine.py
```

This runs three demo stations and prints SMS alerts (English and Nepali) and the alert hashes that would be anchored on-chain.

**2. Smart contract**

1. Open [Remix](https://remix.ethereum.org) and paste in `contracts/FloodRelief.sol`.
2. Compile with Solidity 0.8.20 or newer.
3. Deploy to a testnet (for example Base Sepolia).
4. Try the flow: `setVerifier`, `setNGO`, `createDisaster`, `donate`, `registerHousehold`, `confirmEvacuation`, `submitAidClaim`, `confirmReceipt`.

---

## Roadmap

1. **Prototype (this repo):** contract and risk engine.
2. **Connect the pieces:** web3 integration so alerts are anchored automatically; real SMS gateway.
3. **Pilot:** one flood-prone river basin with local partners (ward offices, Red Cross, local NGOs).
4. **Better prediction:** calibrate the model on historical Nepal data and add glacial lake and landslide-dam monitoring.
5. **Household confirmation:** replace verifier-only receipt with household signature or SMS one-time code; add a donor dashboard.
6. **Security:** independent audit before any mainnet use.

## Limitations

- The risk model is a simple rule-based baseline with placeholder weights, not a validated forecast.
- Identity and verification depend on trusted local verifiers; the contract makes their actions public and auditable but does not remove the need for them.
- Not audited. Do not use with real funds.

## License

MIT
