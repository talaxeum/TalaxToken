var MyNotary = artifacts.require("TalaxToken");
module.exports = function (deployer, network, accounts) {
  deployer.deploy(MyNotary, { from: accounts[0] });
};