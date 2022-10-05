const talaxToken = artifacts.require("TalaxToken");
const whiteList = artifacts.require("WhitelistVesting");

module.exports = function (deployer) {

    deployer.then(async () => {
        let startTimestampPP;
        let durationSecondsPP;
        let startTimestampPS;
        let durationSecondsPS;
        let startTimestampSP;
        let durationSecondsSP;
        let cliffPP;
        let cliffPS;
        let cliffSP;

        await deployer.deploy(talaxToken);

        await deployer.deploy(whiteList, talaxToken.address, cliffPP, startTimestampPP, durationSecondsPP);
        await deployer.deploy(whiteList, talaxToken.address, cliffPS, startTimestampPS, durationSecondsPS);
        await deployer.deploy(whiteList, talaxToken.address, cliffSP, startTimestampSP, durationSecondsSP);
    });
}