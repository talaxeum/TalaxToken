/** @type import('hardhat/config').HardhatUserConfig */
require("hardhat-gas-reporter");
require("hardhat-contract-sizer");
require("@nomiclabs/hardhat-ethers");

module.exports = {
    solidity: "0.8.11",
    contractSizer: {
        alphaSort: true,
        disambiguatePaths: false,
        runOnCompile: true,
        // strict: true,
        // only: [":ERC20$"],
    },
    gasReporter: {
        currency: "ETH",
        gasPrice: 21,
    },
};
