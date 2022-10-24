const ethers = require("ethers");
const { Interface } = require("ethers/lib/utils");
const { abi } = require("../contracts/artifacts/TalaxToken.json");

const iface = new Interface(abi);
const address = iface.encodeFunctionData("mint", [
    "0xaB7C8803962c0f2F5BBBe3FA8bf41cd82AA1923C",
    ethers.utils.parseEther("1.0"),
]);

console.log(address);

const decoded = iface.decodeFunctionData("mint", address);

console.log(decoded);
