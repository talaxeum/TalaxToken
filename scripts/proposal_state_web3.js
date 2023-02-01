const Web3 = require("web3");
const abi = require("../build/contracts/MyGovernor.json");

const web3 = new Web3("https://goerli.infura.io/v3/06f269de6a7d4d749fe987f0b1460181");
const contractAddress = "0x85094B1936bD7287C9444FaA09dCa0B257993832";

let proposalId = "44782053061302158253479573181125706781099996506491438126989206048620935604903";
// proposalId = new web3.utils.BN(proposalId);
// console.log(proposalId);

const contract = new web3.eth.Contract(abi["abi"], contractAddress);
const getter = async () => {
    let state = await contract.methods.state(BigInt(proposalId)).call();
    console.log(state);
};
getter();
