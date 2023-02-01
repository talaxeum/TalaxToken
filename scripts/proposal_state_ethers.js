const ethers = require("ethers");
const fullAbi = require("../build/contracts/MyGovernor.json");

const api = "06f269de6a7d4d749fe987f0b1460181";
const provider = new ethers.providers.InfuraProvider("goerli", api);

const contractAddress = "0x85094B1936bD7287C9444FaA09dCa0B257993832";
const abi = [
    "function name() public view returns (string memory)",
    "function proposalThreshold() public view returns (uint256)",
    "function state(uint256 proposalId) public view returns (ProposalState)",
];

// const governance = new ethers.Contract(contractAddress, abi, provider);
const governance = new ethers.Contract(contractAddress, fullAbi["abi"], provider);

let proposalId = "44782053061302158253479573181125706781099996506491438126989206048620935604903";
proposalId = ethers.BigNumber.from(proposalId);

const getter = async () => {
    let name = await governance.name();
    console.log(name);

    let threshold = await governance.proposalThreshold();
    console.log(threshold.toString());

    // let state = await governance.state(BigInt(proposalId));
    let state = await governance.state(ethers.BigNumber.from(proposalId));
    console.log(state);

    const { againstVotes, forVotes, abstainVotes } = await governance.proposalVotes(BigInt(proposalId));
    console.log(`Votes For: ${forVotes.toString()}`);
    console.log(`Votes Against: ${againstVotes.toString()}`);
    console.log(`Votes Neutral: ${abstainVotes.toString()}\n`);
};

getter();
