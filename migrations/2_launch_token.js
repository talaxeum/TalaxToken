const talaxToken = artifacts.require("TalaxToken");
const stakeContract = artifacts.require("Staking");
const whiteListFactory = artifacts.require("WhitelistFactory");
const vestingFactory = artifacts.require("VestingFactory");

module.exports = async function (deployer, network, accounts) {
    console.log(accounts);
    let startTimestamp = 0; //? provide unix date
    let [durationPS, cliffPS] = [31104000, 5184000]; //? 12 months duration, 2 months cliff
    let [durationPP, cliffPP] = [36288000, 10368000];
    let [durationSP, cliffSP] = [93312000, 28512000];
    let [durationTeamAndProjectContributor, cliffTeamAndProjectContributor] = [93312000, 28512000];

    /**
     *! Notes:
     *? Team and Project Contributor : Beneficiarynya 3 addresses EOA
     *? Staking Reward : Beneficiarynya Contract Staking
     *? Liquidity Reserve : Beneficiarynya EOA
     *? DAO Project Launcher Pool : Beneficiarynya Talax Token, digunakan untuk pendanaan project melalui voting governance
     */
    // let [addressTeam1, addressTeam2, addressTeam3, durationTeamAndProjectContributor, cliffTeamAndProjectContributor] =
    //     ["", "", "", 0, 0];
    let [addressPublicSale, durationPublicSale, cliffPublicSale] = [
        "0x0000000000000000000000000000000000000001",
        10368000,
        0,
    ];
    let [addressMarketing, durationMarketing, cliffMarketing] = [
        "0x0000000000000000000000000000000000000001",
        90720000,
        0,
    ];
    let [addressStaking, durationStakingReward, cliffStakingReward] = [
        "0x0000000000000000000000000000000000000001",
        132192000,
        0,
    ];
    let [addressLiquidityReserve, durationLiquidityReserve, cliffLiquidityReserve] = [
        "0x0000000000000000000000000000000000000001",
        132192000,
        0,
    ];
    let [addressProjectLauncherPool, durationProjectLauncherPool, cliffProjectLauncherPool] = [
        "0x0000000000000000000000000000000000000001",
        132192000,
        0,
    ];

    /* -------------------------------------- Deploy the Token -------------------------------------- */
    await deployer.deploy(talaxToken);

    const talax = await talaxToken.deployed();
    console.log(talax.address);

    /* ---------------------------------- Deploy the Stake Contract --------------------------------- */
    await deployer.deploy(stakeContract, talaxToken.address);

    const stake = await stakeContract.deployed();
    console.log(stake.address);

    /* ------------------------------------ Deploy the Factories ------------------------------------ */
    await deployer.deploy(whiteListFactory);
    await deployer.deploy(vestingFactory);

    const wl_Factory = await whiteListFactory.deployed();
    const v_Factory = await vestingFactory.deployed();

    console.log(wl_Factory.address);
    console.log(v_Factory.address);

    // const instance = await wl_Factory.createWhitelist(talax.address, startTimestamp, durationPP, cliffPP, {
    //     from: accounts[0],
    // });
    // const tx = await wl_Factory.getWhitelist(0, { from: accounts[0] });
    // console.log("Instance receipt: ", instance);
    // console.log("TX receipt: ", tx);

    await wl_Factory.createWhitelist(talax.address, startTimestamp, durationPP, cliffPP);
    await wl_Factory.createWhitelist(talax.address, startTimestamp, durationPS, cliffPS);
    await wl_Factory.createWhitelist(talax.address, startTimestamp, durationSP, cliffSP);
    await wl_Factory.createWhitelist(
        talax.address,
        startTimestamp,
        durationTeamAndProjectContributor,
        cliffTeamAndProjectContributor
    );

    // //createVestingTeam (can be categorized as whitelist with only 3 beneficiaries)
    await v_Factory.createVesting(
        talax.address,
        addressPublicSale,
        startTimestamp,
        durationPublicSale,
        cliffPublicSale
    );
    await v_Factory.createVesting(talax.address, addressMarketing, startTimestamp, durationMarketing, cliffMarketing);
    await v_Factory.createVesting(
        talax.address,
        addressStaking,
        startTimestamp,
        durationStakingReward,
        cliffStakingReward
    );
    await v_Factory.createVesting(
        talax.address,
        addressLiquidityReserve,
        startTimestamp,
        durationLiquidityReserve,
        cliffLiquidityReserve
    );
    await v_Factory.createVesting(
        talax.address,
        addressProjectLauncherPool,
        startTimestamp,
        durationProjectLauncherPool,
        cliffProjectLauncherPool
    );
};