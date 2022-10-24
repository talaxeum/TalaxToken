var MyNotary = artifacts.require("Talaxeum");
module.exports = function (deployer, network, accounts) {
    deployer.deploy(MyNotary, { from: accounts[0] });
};
