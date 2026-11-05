
# ProofBoard — Project Context

## Overview
ProofBoard is a Web3 contribution recognition dApp.

Contributors submit evidence of developer contributions.
An administrator reviews submissions.
Approved contributors receive ERC-721 NFT badges.

## Core Workflow
1. Connect Ethereum wallet using MetaMask.
2. Submit contribution title and public proof URL.
3. Administrator approves or rejects submission.
4. Approval mints an NFT badge to the contributor.
5. Explore contributions and earned badges.

## Existing Frontend
- React 18 + HTM
- Vite
- CSS
- Single-page application in src/main.js
- Styles in src/styles.css
- Mock contributions and simulated interactions

IMPORTANT:
The existing frontend design is approved.
Preserve all layouts, styling, animations, and components.
Replace simulated behavior incrementally.

## Blockchain
- Solidity ^0.8.20
- OpenZeppelin ERC-721
- Ethereum Sepolia
- Remix IDE for compilation and deployment
- MetaMask for wallet transactions
- ethers.js for frontend integration

## MVP Features
- Wallet connection
- Contribution submission
- Administrator review
- NFT badge minting
- Contribution explorer
- Badge gallery

## Smart Contract Requirements
- Submit a contribution.
- Approve and mint a badge.
- Reject a contribution.
- Read contribution details.
- Read total contribution count.
- Only the contract owner can approve/reject.
- Prevent duplicate reviews.
- Emit relevant events.

## Scope Restrictions
Do not add:
- Backend services
- Databases
- DAO governance
- Token economics
- Cross-chain functionality
- Complex authentication
- Unrequested features

## Development Approach
- Implement one feature at a time.
- Preserve existing functionality.
- Prefer simple, verifiable implementations.
- Wait for explicit instructions between tasks.
