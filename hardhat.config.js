/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-contract-sizer");

module.exports = {
    solidity: "0.8.11",
    settings: {
        optimizer: {
            enabled: true,
            runs: 1000,
        },
    },
    contractSizer: {
        alphaSort: true,
        disambiguatePaths: false,
        runOnCompile: true,
        strict: false,
        // only: [":ERC20$"],
    },
};
