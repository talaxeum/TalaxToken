// var MyNotary = artifacts.require("TalaxToken");
// module.exports = function (deployer, network, accounts) {
//   deployer.deploy(MyNotary, { from: accounts[0] });
// };

var MyGovernor = artifacts.require("MyGovernor");
module.exports = function (deployer, network, accounts) {
    deployer.deploy(MyGovernor, { from: accounts[0] });
};
