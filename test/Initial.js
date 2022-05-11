const TalaxToken = artifacts.require("TalaxToken");
const { assert, expect } = require("chai");
const { before } = require("lodash");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

describe("Initial", async (accounts) => {
    beforeEach(async () => {
        this.talax = await TalaxToken.new();
    });

    it("Initial: initial owner", async () => {
        owner = await this.talax.getOwner();
        console.log("Owners: ", owner);

        assert.equal(accounts[0], owner, "Owner should be gnosis safe address");
    });

    it("Initial: transfer owner", async () => {
        owner = await this.talax.getOwner();
        console.log("Owners: ", owner);

        let newOwners = accounts[1];

        await this.talax.transferOwnership(newOwners, { from: accounts[0] });

        owner = await this.talax.getOwner();
        console.log("Owners: ", owner);
    });

    it("Initial: change tax fee from not owner", async () => {
        owner = await this.talax.getOwner();
        console.log(owner);

        try {
            await this.talax.changeTaxFee(2, { from: accounts[3] });
        } catch (err) {
            console.log(err.reason);
            assert.equal(
                err.reason,
                "Ownable: caller is not the owner",
                "Failed to notice not owner validation"
            );
        }
    });

    it("Initial: change tax fee account 1", async () => {
        owner = await this.talax.getOwner();
        console.log("Owners: ", owner);

        await this.talax.changeTaxFee(2, { from: accounts[1] });

        let tax = await this.talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("Initial: change tax fee account 2", async () => {
        owner = await this.talax.getOwner();
        console.log("Owners: ", owner);

        await helper.advanceTimeAndBlock(2 * 24 * 3600);
        await this.talax.changeTaxFee(2, { from: accounts[1] });

        let tax = await this.talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("Initial: cannot call 2 administrative functions under 48 hours", async () => {
        thisAddress = await this.talax.thisAddress();
        let balance = await this.talax.balanceOf(thisAddress);
        console.log("Balance: ", balance.toString());

        try {
            await this.talax.mintLiquidityReserve(10000, { from: accounts[1] });
        } catch (err) {
            console.log(err.reason);
            assert.equal(
                err.reason,
                "Timelock: Administrative functions cannot be called in this TimeLock period (48 hours), please try again later.",
                "Failed to notice not Timelock functions"
            );
        }
    });
});
