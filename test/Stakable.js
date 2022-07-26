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

        await truffleAssert.reverts(
            talax.stake(1000, 10, { from: accounts[1] }),
            "Staking option doesnt exist"
        );

        await truffleAssert.reverts(
            talax.stake(0, 90 * 24 * 3600, { from: accounts[1] }),
            "Cannot stake nothing"
        );
    });
});
