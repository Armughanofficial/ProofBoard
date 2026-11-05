# ProofBoard

### Your commits deserve a place on the wall.

**ProofBoard** is an on-chain contribution recognition platform that transforms verified developer contributions into unique, generative NFT badges.

Built on Ethereum Sepolia, ProofBoard connects open-source contributions with transparent review, blockchain-backed recognition, and collectible digital credentials.

**[Live Application](https://proofboard-web3.vercel.app/)** · **[Smart Contract on Etherscan](https://sepolia.etherscan.io/address/0x4873D1B0C76588A66Cc4e8675e920bF12389E62c)**

---

## The Problem

Open-source projects thrive on contributions, but recognition often remains fragmented across repositories, pull requests, and community platforms.

Developers contribute code, documentation, designs, and security improvements, yet there is rarely a unified way to turn those contributions into portable, verifiable recognition.

**ProofBoard bridges that gap.**

Contributors submit evidence of their work, maintainers review submissions, and approved contributors receive unique NFT badges that represent their contributions.

## How ProofBoard Works

**Submit → Review → Approve → Mint → Showcase**

### 1. Connect Your Wallet

Visit the [ProofBoard dApp](https://proofboard-web3.vercel.app/) and click **Connect Wallet**.

- Connect your MetaMask wallet.
- Select the Ethereum Sepolia test network.
- Approve the wallet connection request.

ProofBoard uses your wallet address to associate submissions with contributors and deliver NFT badges.

### 2. Submit a Contribution

Navigate to **Submit proof** and provide:

- **Contribution title:** A concise description of your work.
- **Proof URL:** A GitHub repository, pull request, or another relevant evidence link.
- **Category:** Code, Docs, Design, or Security.

Click **Submit** and confirm the transaction in MetaMask.

The contribution is recorded on-chain with a pending review status.

### 3. Maintainer Review

ProofBoard uses an owner-controlled review mechanism to recognize contributions.

The contract owner can:

- Enable the **Admin review** toggle.
- Browse pending contributions.
- Approve or reject submitted proofs.
- Confirm review transactions through MetaMask.

**Only the smart contract owner can approve or reject contributions.** Enabling the Admin Review toggle exposes the interface controls but does not grant blockchain permissions.

### 4. NFT Minting

When a contribution is approved, the smart contract automatically mints a unique **ERC-721 NFT badge** to the contributor's wallet.

Each badge contains:

- A unique token ID.
- The contribution title.
- A contribution category.
- Generative SVG artwork.
- On-chain metadata.

The artwork uses category-specific visual styling to distinguish different types of contributions.

### 5. Explore and Verify

Open **Explorer** to browse submissions and their approval status.

Navigate to **Gallery** to view minted badges and their associated contribution details.

To inspect your NFT directly:

1. Open MetaMask.
2. Switch to Sepolia.
3. Navigate to the **NFTs** section.
4. Select your ProofBoard badge to view its metadata, token ID, and contract address.

You can also independently inspect the deployed smart contract and its transaction history on [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x4873D1B0C76588A66Cc4e8675e920bF12389E62c).

---

## Core Features

| Feature | Description |
|---|---|
| Wallet Integration | MetaMask connectivity through ethers.js |
| On-Chain Submissions | Contributions recorded directly on Ethereum Sepolia |
| Maintainer Review | Owner-restricted approval and rejection |
| NFT Recognition | ERC-721 badges minted for approved contributions |
| Generative Artwork | Category-specific, programmatically generated SVG badges |
| On-Chain Metadata | NFT metadata and artwork generated within the smart contract |
| Contribution Explorer | Browse contributions and review statuses |
| NFT Gallery | View badges and associated contributor information |
| Blockchain Transparency | Inspect transactions and token ownership on Sepolia |

## Contribution Categories

ProofBoard currently supports four contribution categories:

**Code** — Smart contracts, application development, infrastructure, and software implementation.

**Docs** — Technical documentation, tutorials, developer guides, and educational resources.

**Design** — Interface design, visual assets, user experience, and creative contributions.

**Security** — Security research, audits, vulnerability identification, and protective improvements.

Each category receives its own visual identity through the generative NFT artwork system.

---

## Architecture

ProofBoard follows a client-to-blockchain architecture, with MetaMask acting as the wallet provider.

```text
Contributor / Maintainer
          |
          v
    ProofBoard dApp
      (Vite + UI)
          |
          v
       ethers.js
          |
          v
       MetaMask
          |
          v
    Ethereum Sepolia
          |
          v
 ProofBoard Smart Contract
          |
          +-- Contribution Records
          +-- Review and Approval
          +-- ERC-721 NFT Minting
          +-- On-Chain SVG Metadata
```

The frontend communicates directly with the deployed smart contract. No centralized application backend is required for the core submission, review, or minting workflow.

### Smart Contract

The ProofBoard smart contract is written in Solidity and uses OpenZeppelin's ERC-721 and Ownable implementations.

| Function | Description | Access |
|---|---|---|
| `submitContribution()` | Submit a new contribution for review | Public |
| `approveContribution()` | Approve a contribution and mint an NFT | Owner |
| `rejectContribution()` | Reject a pending contribution | Owner |
| `getContribution()` | Retrieve contribution details | Public read |
| `getContributionCount()` | Retrieve the total number of submissions | Public read |
| `getContributionCategory()` | Retrieve a contribution's category | Public read |
| `tokenURI()` | Generate and return NFT metadata | Public read |
| `ownerOf()` | Identify the owner of a minted NFT | Public read |

### On-Chain Generative NFTs

ProofBoard generates NFT artwork directly within the Solidity contract.

Each badge uses SVG-based artwork with geometric patterns, category-specific gradients, contribution titles, and unique token identifiers.

Metadata and artwork are encoded using Base64 data URIs, allowing the NFT to be rendered without depending on an external image-hosting server.

---

## Technology Stack

| Component | Technology |
|---|---|
| Blockchain | Ethereum Sepolia |
| Smart Contracts | Solidity |
| NFT Standard | ERC-721 |
| Libraries | OpenZeppelin |
| Development | Hardhat, Remix IDE |
| Frontend | Vite, JavaScript, React/HTM |
| Blockchain Integration | ethers.js |
| Wallet | MetaMask |
| Hosting | Vercel |
| Blockchain Explorer | Etherscan |
| Version Control | Git, GitHub |

## Live Deployment

**Application:** https://proofboard-web3.vercel.app/

**Network:** Ethereum Sepolia Testnet

**Chain ID:** `11155111`

**Smart Contract Address:**

`0x4873D1B0C76588A66Cc4e8675e920bF12389E62c`

**Etherscan:** https://sepolia.etherscan.io/address/0x4873D1B0C76588A66Cc4e8675e920bF12389E62c

ProofBoard is deployed on Sepolia for testing and demonstration. Interacting with the smart contract requires Sepolia test ETH for gas fees.

---

## Getting Started

### Prerequisites

- Node.js and npm
- MetaMask browser extension
- Ethereum Sepolia network configured in MetaMask
- Sepolia test ETH for blockchain transactions

### Clone the Repository

```bash
git clone https://github.com/Armughanofficial/ProofBoard.git
cd ProofBoard
```

### Run the Frontend

The Vite frontend is located in the inner `ProofBoard/` directory.

```bash
cd ProofBoard
npm install
npm run dev
```

Open the development URL displayed in the terminal, typically `http://localhost:5173`.

The frontend is configured to communicate with the publicly deployed Sepolia contract.

### Smart Contract Development

From the repository root:

```bash
npm install
npx hardhat compile
```

Start a local Hardhat node:

```bash
npx hardhat node
```

To deploy to a local network, use the deployment script with the appropriate Hardhat network configuration.

**Note:** A local Hardhat deployment uses a different chain ID and contract address. Update the frontend configuration before connecting it to a local deployment.

## Project Structure

```text
ProofBoard/
├── contracts/
│   └── ProofBoard.sol
├── scripts/
│   └── deploy.ts
├── hardhat.config.ts
├── package.json
├── README.md
└── ProofBoard/
    ├── index.html
    ├── src/
    │   ├── main.js
    │   └── styles.css
    ├── public/
    └── package.json
```

---

## Security Considerations

- Only the contract owner can approve or reject submissions.
- All blockchain write operations require wallet confirmation.
- Contributor-supplied proof links must be reviewed before approval.
- Approval represents a maintainer's review decision, not independent cryptographic verification of the submitted work.
- Sepolia is a test network, and its ETH has no real monetary value.
- Never expose wallet private keys, seed phrases, or sensitive environment credentials.

## Roadmap

ProofBoard currently demonstrates a complete contribution-to-recognition workflow. Potential future improvements include:

- **Multi-maintainer governance:** Support distributed contribution review.
- **GitHub verification:** Connect submissions with repository and pull-request activity.
- **Contributor profiles:** Showcase contributions and earned badges in one place.
- **Reputation systems:** Introduce achievement tiers and contribution milestones.
- **Multi-chain support:** Extend recognition to additional EVM-compatible networks.
- **Advanced analytics:** Track contributions, approvals, and community participation.

---

### ProofBoard — Your commits deserve a place on the wall.

**[Launch ProofBoard](https://proofboard-web3.vercel.app/)** · **[Explore the Contract](https://sepolia.etherscan.io/address/0x4873D1B0C76588A66Cc4e8675e920bF12389E62c)**