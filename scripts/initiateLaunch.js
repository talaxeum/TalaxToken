const ethers = require("ethers");
const fs = require("fs");

const vestingFactory = JSON.parse(
    fs.readFileSync("../artifacts/contracts/Factories/VestingFactory.sol/VestingFactory.json")
);
const vestingFactoryAbi = vestingFactory["abi"];
const vestingFactoryAddress = "";

const whitelistFactory = JSON.parse(
    fs.readFileSync("../artifacts/contracts/Factories/WhitelistFactory.sol/WhitelistFactory.json")
);
const whitelistFactoryAbi = whitelistFactory["abi"];
const whitelistFactoryAddress = "";

//to create 'signer' object;here 'account'
const mnemonic = ""; // seed phrase for your Metamask account
const provider = new ethers.providers.JsonRpcProvider("https://endpoints.omniatech.io/v1/bsc/testnet/public"); // testnet smart chain
const wallet = ethers.Wallet.fromMnemonic(mnemonic);
const account = wallet.connect(provider);

/* ------------------------------------------- Params ------------------------------------------- */

/* -------------------------------------- Contract Creation ------------------------------------- */
const vestingFactoryContract = new ethers.Contract(vestingFactoryAddress, vestingFactoryAbi, account);
const whitelistFactoryContract = new ethers.Contract(whitelistFactoryAddress, whitelistFactoryAbi, account);
