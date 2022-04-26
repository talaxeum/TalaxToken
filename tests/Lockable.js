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
    // TalaxToken.defaults({
    //     gasPrice:0,
    // });

    it("Not yet Claimable Test", async () => {
        talax = await TalaxToken.deployed();
        owner = accounts[1];

        let balance = await talax.balanceOf(owner);
        console.log("Starting Balance: ", balance.toString());

        try {
            console.log(talax.address.toString());
            await talax.unlockTeamAndProjectCoordinatorWallet_1({
                from: owner,
            });
        } catch (error) {
            console.log(error.reason);
            assert.equal(
                error.reason,
                "Lockable: There's nothing to claim yet",
                "Failed to notice a 0 withdrawal from Owner"
            );
        }

        balance = await talax.balanceOf(owner);
        console.log("End Balance: ", balance.toString());
    });

    it("Wrong Owner Claim Test", async () => {
        talax = await TalaxToken.deployed();
        stranger = accounts[0];

        try {
            await talax.unlockTeamAndProjectCoordinatorWallet_1({
                from: stranger,
            });
        } catch (error) {
            assert.equal(
                error.reason,
                "TalaxToken: Wallet Owner Only",
                "Failed to notice wrong owner claim from DevPool"
            );
        }
    });

    it("Claim after the Designated Time Test", async () => {
        talax = await TalaxToken.deployed();
        owner = accounts[1];

        let balance = await talax.balanceOf(owner);
        console.log("Starting Balance: ", balance.toString());

        await helper.advanceTimeAndBlock(3600 * 24 * 120);
        await talax.unlockTeamAndProjectCoordinatorWallet_1({ from: owner });

        balance = await talax.balanceOf(owner);
        console.log("Balance after Claim: ", balance.toString());
    });
});
