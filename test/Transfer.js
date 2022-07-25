const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Transfer", async (accounts) => {
    let talax;
    let owner = accounts[0];
    before(async () => {
        talax = await TalaxToken.deployed();
    });

    it("Transfer: basic transfer to accounts[1]", async () => {
        ownerStartBalance = parseFloat(await talax.balanceOf(owner));

        try {
            await talax.transfer(accounts[1], 1000, { from: accounts[0] });
        } catch (err) {
            console.log(err);
        }

        ownerEndBalance = parseFloat(await talax.balanceOf(owner));
        balance = parseFloat(await talax.balanceOf(accounts[1]));
        assert.equal(
            ownerEndBalance,
            ownerStartBalance - 1000,
            "Wrong end balance"
        );
        assert.equal(990, balance, "Wrong end balance");
    });
});
