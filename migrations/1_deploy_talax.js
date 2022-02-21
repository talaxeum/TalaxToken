const Migrations = artifacts.require("Migrations");
const TalaxToken = artifacts.require("TalaxToken");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(TalaxToken);
};
