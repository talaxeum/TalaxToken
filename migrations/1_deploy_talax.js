const Migrations = artifacts.require("TalaxToken");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
