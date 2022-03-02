const TalaxToken = artifacts.require("TalaxToken");

module.exports = function (deployer) {
  deployer.deploy(TalaxToken);
};
