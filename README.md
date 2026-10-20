# FloodGuard: Blockchain Early Warning & Relief

**Blockchain-Based Flood Early Warning and Transparent Disaster Relief System for Nepal**

![FloodGuard architecture](docs/architecture.png)

> FloodGuard is an independent personal project and proof of concept, built from a desire to do something practical about the impact of floods in Nepal. This repository describes an initial prototype with a Solidity smart contract and a Python risk engine. The prototype is unaudited, intended for testnet experimentation only, and must not be used with real funds or for operational flood warnings.

## Proposal answers

### Title (max 50 words)

Blockchain-Based Flood Early Warning and Transparent Disaster Relief System for Nepal

### Title (50 characters or fewer)

FloodGuard: Blockchain Early Warning & Relief

### Short description (140 characters or fewer)

After losing loved ones in Nepal's floods, I'm building FloodGuard: AI flood alerts plus blockchain-verified, transparent relief.

### Image

`docs/architecture.png` (1300 × 732 px)

### Project context

This is a self-directed project, not an official project or submission on behalf of an organization.

### What problem do you want to solve using blockchain, crypto, or decentralized finance?

*Who is affected by this problem, and why does it matter?*

Flood-prone communities in Nepal and the Himalayan region can face sudden floods with little warning, followed by slow or opaque relief. The original proposal cites figures for the August 2026 Bhote Koshi flash flood: 1,342 deaths, nearly 4,900 people missing or out of contact by 6 September, and 84,270 people affected across 17 municipalities in six districts. These are high-stakes, time-sensitive figures reproduced from the proposal and have not been independently verified for this README. Confirm them against dated primary reports before publication or use; “missing or out of contact” should not be restated as confirmed missing persons.

After a disaster, trust can break down. Donors may not be able to see where money goes. Affected people can be missed or counted more than once. Aid can be delayed by paperwork or diverted by fraud. Early warnings need to be fast, while relief needs to be verifiable. Blockchain may help with the latter: donors, government, NGOs, and communities that do not fully trust one another can share a common record.

### What is your idea?

*Briefly describe how blockchain, tokenization, or decentralized ownership could help solve this problem.*

FloodGuard uses blockchain for verification during relief, while keeping time-sensitive warnings off-chain.

Sensors, weather data, and satellite imagery are intended to feed a risk engine that can send early SMS alerts to at-risk communities. Alerts would be sent without blockchain, because speed matters most. Alert, evacuation, and household records could then be written to a shared blockchain ledger for participating ward officials, rescue teams, NGOs, and donors. Donations would be held in smart contracts and released after specified evacuation and aid-delivery checks. Household identifiers would be represented as hashes rather than personal data on-chain.

These are proposed capabilities, not validated outcomes. A hash alone does not guarantee privacy, prevent duplicate identities, or prove that aid reached a household; those depend on sound system design and trusted verification.

### What makes your idea innovative or different?

*What makes this approach stand out from existing solutions?*

FloodGuard proposes using blockchain to make disaster-relief activity more transparent and traceable. A shared ledger could record donations, fund transfers, evacuation confirmations, and aid delivery. Smart contracts could automate fund distribution to approved NGOs or suppliers after predefined checks. Donors and participating local organizations could review records without relying on one organization to maintain the only copy.

The proposed distinction is a verifiable shared record for relief activities. A ledger cannot by itself establish that off-chain reports are true, prevent collusion, or ensure that aid is distributed fairly; those require accountable local processes and independent oversight.

### Who would benefit from your solution, and how?

*What positive impact could your idea have?*

The initial focus is flood-prone communities in Nepal. The project aims to deliver warnings to ordinary phones, support more consistent aid registration, give donors a clearer record of fund movement, and reduce paperwork and disputes for NGOs and local authorities. These are goals, not demonstrated results.

The proposal sets a target of reaching 1 million people across the Great Himalayan region. It also cites global estimates of around 1.47 billion people facing significant flood risk and average annual flood losses of about $388 billion. These figures are reproduced from the supplied proposal and are not independently verified here; add dated sources and definitions before presenting them as established facts. The approach may be adaptable to other flood-prone regions if tested with local partners.

### Why do you want to work on this idea?

*What inspired you to tackle this problem?*

I have lost people close to me in Nepal's floods. I cannot bring them back, but I feel I have to do something. I want to work toward a future where communities get warnings in time and help reaches people who need it without delay or waste.

### Optional: pitch deck (PDF, max 10 slides)

Not applicable; this is an independent project.

### Optional: link to supporting documentation

Not applicable; this is an independent project.

### Optional: video URL (YouTube or Vimeo, max 2 minutes)

Not provided.

## How it works

```text
Sensors + weather + satellite data → risk scoring → local alerts → verified evacuation → transparent aid tracking
       (off-chain, speed-focused)                                  (on-chain, auditable record)
```

| Step | Component | On-chain? |
| --- | --- | --- |
| Sense river level, rainfall, soil conditions, and upstream hazards | `risk_engine/` | No; speed matters |
| Score risk and choose an alert level | `risk_engine/risk_engine.py` | No |
| Send SMS in English and Nepali | `send_sms()` stub | No |
| Anchor a hash of each alert | `anchorAlert()` | Yes |
| Register households and confirm evacuation | `registerHousehold()`, `confirmEvacuation()` | Yes |
| Donate to a disaster pool | `donate()` | Yes |
| NGO submits an aid claim for a verified household | `submitAidClaim()` | Yes |
| Verifier confirms receipt and funds are released | `confirmReceipt()` | Yes |

### Smart-contract roles

- **Admin:** deploys the contract, creates disasters, and assigns roles.
- **Oracle:** the FloodGuard server, which can anchor alert hashes.
- **Verifier:** ward officials or rescue teams, who register households and confirm evacuation and receipt.
- **NGO:** whitelisted relief organizations, which submit aid claims and receive payouts.
- **Donor:** anyone who can donate to an active disaster pool.

### Built-in safeguards (as designed in the prototype)

- One registration per household per disaster to limit duplicate counting.
- One aid claim per household per disaster to limit duplicate claims.
- Aid claims are restricted to registered households with evacuation confirmed.
- A per-household aid cap; funds are reserved before payout.
- Payment to the NGO follows verifier confirmation of receipt.
- Household identifiers are represented as hashes; no personal data should be placed on-chain.

These controls depend on correct contract implementation and reliable inputs from authorized users. They do not guarantee that real-world identities or reports are accurate.

## Repository structure

```text
floodguard/
├── README.md
├── docs/
│   └── architecture.png       # System diagram
├── contracts/
│   └── FloodRelief.sol        # Donation pool and verified aid release
└── risk_engine/
    └── risk_engine.py         # Rule-based risk scoring, alerts, and hash anchoring
```

## Quick start

### 1. Risk engine

Requires Python 3.8 or newer. The supplied prototype has no external dependencies.

```bash
python risk_engine/risk_engine.py
```

This runs three demo stations and prints sample SMS alerts in English and Nepali, along with alert hashes that could be anchored on-chain. The demo is not an operational warning service and must not be used to make safety decisions.

### 2. Smart contract

1. Open [Remix](https://remix.ethereum.org/) and paste in `contracts/FloodRelief.sol`.
2. Compile with Solidity 0.8.20 or newer.
3. For experimentation only, deploy to a testnet such as Base Sepolia.
4. Explore the flow: `setVerifier`, `setNGO`, `createDisaster`, `donate`, `registerHousehold`, `confirmEvacuation`, `submitAidClaim`, and `confirmReceipt`.

Do not send real funds to this prototype. Testnet deployment does not imply security or readiness for production.

## Roadmap

1. **Prototype (this repository):** smart contract and risk engine.
2. **Connect the pieces:** add Web3 integration to anchor alerts automatically and connect a real SMS gateway.
3. **Pilot:** work with local community and emergency-response partners in one flood-prone river basin.
4. **Improve prediction:** calibrate the model on historical Nepal data and add glacial-lake and landslide-dam monitoring.
5. **Household confirmation:** replace verifier-only receipt confirmation with a household signature or SMS one-time code, and add a donor dashboard.
6. **Security:** obtain an independent audit before considering any mainnet use.

## Limitations and safety

- The risk model is a simple rule-based baseline with placeholder weights, not a validated forecast.
- The repository's sensor, weather, and satellite inputs and SMS delivery are not established as production integrations; `send_sms()` is a stub.
- Identity and verification depend on trusted local verifiers. A public record can make their actions reviewable but cannot ensure that those actions are correct.
- On-chain hashes and records may still create privacy risks, and blockchain transactions may be difficult or impossible to reverse.
- This prototype has not been independently audited. **Do not use it for real funds, mainnet deployment, emergency alerts, evacuation decisions, or operational relief distribution.**
- The disaster and global flood statistics in the proposal require verification against dated primary sources before external publication.

## Project Credits

FloodGuard was conceptualized and developed by **Pratik Pokhrel** as an independent proof-of-concept project. It reflects a personal motivation to do something constructive in response to flooding in Nepal and is not affiliated with an organization.

## License

MIT License

Copyright (c) 2026 Pratik Pokhrel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
