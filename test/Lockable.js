const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Lockable", async (accounts) => {
    let talax;
    let owner = accounts[0];
    before(async () => {
        talax = await TalaxToken.deployed();
    });

    it("Lockable: initiate lockwallet", async () => {
        try {
            await talax.initiateLockedWallet_PrivateSale_Airdrop({
                from: owner,
            });
        } catch (err) {
            console.error(err.reason);
        }
    });

    it("Lockable: check unlocked amount", async () => {
        try {
            await talax.unlockPrivatePlacementWallet({
                from: accounts[1],
            });
        } catch (err) {
            console.log("Lockable:", err.reason);
        }

        balance = parseFloat(await talax.balanceOf(accounts[1]));
        assert.equal(
            balance,
            4370625 * 1e18,
            "Lockable: Wrong amount unlocked"
        );
    });
});
