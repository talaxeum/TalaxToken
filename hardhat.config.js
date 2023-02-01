/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("hardhat-contract-sizer");
require("hardhat-gas-reporter");

module.exports = {
    solidity: {
        version: "0.8.11",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    contractSizer: {
        alphaSort: true,
        disambiguatePaths: false,
        runOnCompile: true,
        // strict: true,
        // only: [":ERC20$"],
    },
    gasReporter: {
        enabled: true,
        currency: "ETH",
        gasPrice: 21,
    },
};
