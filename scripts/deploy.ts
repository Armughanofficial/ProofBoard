import { network } from "hardhat";

const { ethers } = await network.connect();

const [deployer] = await ethers.getSigners();

console.log("Deploying ProofBoard with:", deployer.address);

const proofBoard = await ethers.deployContract("ProofBoard");
await proofBoard.waitForDeployment();

console.log("ProofBoard deployed at:", await proofBoard.getAddress());
