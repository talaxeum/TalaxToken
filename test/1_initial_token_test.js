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

        assert.strictEqual(
            supply,
            parseFloat(
                (21000000 * 1e3 * 1e18).toFixed(0) -
                    (14114100 * 1e3 * 1e18).toFixed(0)
            ),
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

        assert.strictEqual(
            stakingReward,
            parseFloat((2685900 * 1e3 * 1e18).toFixed(0)),
            "Staking Reward wrong amount"
        );
        assert.equal(DAO, 4200000 * 1e3 * 1e18, "DAO wrong amount");
    });

    it("Initial: initial taxFee", async () => {
        tax = parseFloat(await talax.taxFee());

        assert.equal(1, tax, "Tax wrong amount");
    });

    it("Initial: initial statuses", async () => {
        airdrop = await talax.airdropStatus();
        initialization = await talax.initializationStatus();

        assert.equal(airdrop, false, "airdrop wrong status");
        assert.equal(initialization, false, "initialization wrong status");
    });

    it("Initial: initialized", async () => {
        airdrop = await talax.airdropStatus();
        initialization = await talax.initializationStatus();

        assert.equal(airdrop, false, "airdrop wrong status");
        assert.equal(initialization, false, "initialization wrong status");

        try {
            await talax.initiateLockedWallet_PrivateSale_Airdrop({
                from: accounts[1],
            });
        } catch (err) {
            console.error("Initializing from acc 1", err.reason);
        }

        try {
            await talax.initiateLockedWallet_PrivateSale_Airdrop({
                from: owner,
            });
        } catch (err) {
            console.error(err.reason);
        }

        airdrop = await talax.airdropStatus();
        initialization = await talax.initializationStatus();

        assert.equal(airdrop, true, "airdrop wrong status");
        assert.equal(initialization, true, "initialization wrong status");
    });
});
