const ethers = require("ethers");
const { Interface } = require("ethers/lib/utils");
const { abi } = require("../artifacts/contracts/TalaxToken.sol/TalaxToken.json");

const iface = new Interface(abi);
const calldata = iface.encodeFunctionData("mint", [
    "0xaB7C8803962c0f2F5BBBe3FA8bf41cd82AA1923C",
    ethers.utils.parseEther("1.0"),
]);

console.log(calldata);

const decodedData = iface.decodeFunctionData("mint", calldata);

console.log(decodedData);
