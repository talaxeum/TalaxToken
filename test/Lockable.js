const TalaxToken = artifacts.require("TalaxToken");
const { assert, expect } = require("chai");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

describe("Lockable", async (accounts) => {
    // TalaxToken.defaults({
    //     gasPrice:0,
    // });
    beforeEach(async () => {
        this.talax = await TalaxToken.new();
    });

    it("Not yet Claimable Test", async () => {
        owner = accounts[1];

        let balance = await this.talax.balanceOf(owner);
        console.log("Starting Balance: ", balance.toString());

        try {
            console.log(this.talax.address.toString());
            await this.talax.unlockTeamAndProjectCoordinatorWallet_1({
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

        balance = await this.talax.balanceOf(owner);
        console.log("End Balance: ", balance.toString());
    });

    it("Wrong Owner Claim Test", async () => {
        stranger = accounts[0];

        try {
            await this.talax.unlockTeamAndProjectCoordinatorWallet_1({
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
        owner = accounts[1];

        let balance = await this.talax.balanceOf(owner);
        console.log("Starting Balance: ", balance.toString());

        await helper.advanceTimeAndBlock(3600 * 24 * 120);
        await this.talax.unlockTeamAndProjectCoordinatorWallet_1({ from: owner });

        balance = await this.talax.balanceOf(owner);
        console.log("Balance after Claim: ", balance.toString());
    });
});
