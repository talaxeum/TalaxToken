const Staking = artifacts.require("Staking");
// const { assert } = require("chai");
// const truffleAssert = require("truffle-assertions");
// const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Staking", (accounts) => {
    it("Staking: check empty withdraw", async () => {
        try {
            let staking = await Staking.deployed();
            await staking.withdrawStake({ from: accounts[0] });
        } catch (err) {
            console.log(err);
        }
    });
});
