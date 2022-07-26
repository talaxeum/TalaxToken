const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Stakable", async (accounts) => {
    let talax;
    let owner = accounts[0];
    before(async () => {
        talax = await TalaxToken.deployed();
    });

    it("Stakable: staking", async () => {
        await talax.transfer(accounts[1], 10000, { from: owner });
        await talax.transfer(accounts[2], 10000, { from: owner });

        // Invoke revert staking option not exist
        await truffleAssert.reverts(
            talax.stake(1000, 10, { from: accounts[1] }),
            "Staking option doesnt exist"
        );

        // Invoke revert cannot stake without amount
        await truffleAssert.reverts(
            talax.stake(0, 90 * 24 * 3600, { from: accounts[1] }),
            "Cannot stake nothing"
        );

        await talax.stake(1000, 90 * 24 * 3600, { from: accounts[2] });

        // Invoke revert cannot stake if user already have a stake
        await truffleAssert.reverts(
            talax.stake(1000, 90 * 24 * 3600, { from: accounts[2] }),
            "User is a staker"
        );
    });

    //? Account[1] staked 1000 token for 90 days

    it("Stakable: assert value returned after staking", async () => {
        await helper.advanceTimeAndBlock(30 * 24 * 3600);
        hasStake = await talax.hasStake({ from: accounts[2] });
        console.log(hasStake);

        await talax.withdrawStake({ from: accounts[2] });
        await helper.advanceTimeAndBlock(5 * 60);
        balance = parseFloat(await talax.balanceOf(accounts[2]));
        assert.equal(balance, 9889, "Wrong amount of unstake");
    });
});
