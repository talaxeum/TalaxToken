const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Initial", async (accounts) => {
    let talax;
    before(async () => {
        talax = await TalaxToken.deployed();
    });

    it("Initial: initial supply", async () => {
        supply = parseFloat(await talax.totalSupply());
        console.log("Total Supply: ", supply);

        assert.equal(
            21 * 1e9 * 1e18 - 14114100 * 1e3 * 1e18,
            supply,
            "Total Supply should be 6885900 * 1e3 * 1e18"
        );
    });

    it("Initial: initial owner", async () => {
        owner = await talax.owner();
        console.log("Owners: ", owner);

        assert.equal(accounts[0], owner, "Owner should be gnosis safe address");
    });

    it("Initial: initial amount", async () => {
        stakingReward = parseFloat(await talax.stakingReward());
        DAO = parseFloat(await talax.daoProjectPool());

        assert.equal(
            2685900 * 1e3 * 1e18,
            stakingReward,
            "Staking Reward wrong amount"
        );
        assert.equal(4200000 * 1e3 * 1e18, DAO, "DAO wrong amount");
    });

    it("Initial: initial taxFee", async () => {
        tax = parseFloat(await talax.taxFee());

        assert.equal(1, tax, "Tax wrong amount");
    });

    it("Initial: initial statuses", async () => {
        airdrop = await talax.airdropStatus();
        initialization = await talax.initializationStatus();

        assert.equal(false, airdrop, "airdrop wrong status");
        assert.equal(false, initialization, "initialization wrong status");
    });
});
