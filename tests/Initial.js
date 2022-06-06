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
    it("Initial: initial owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        assert.equal(accounts[0], owner, "Owner should be gnosis safe address");
    });

    it("Initial: transfer owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        let newOwners = accounts[1];

        await talax.transferOwnership(newOwners, { from: accounts[0] });

        owner = await talax.getOwner();
        console.log("Owners: ", owner);
    });

    it("Initial: change tax fee from not owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log(owner);

        try {
            await talax.changeTaxFee(2, { from: accounts[3] });
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
        let talax = await TalaxToken.deployed();

        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        await talax.changeTaxFee(2, { from: accounts[1] });

        let tax = await talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("Initial: change tax fee account 2", async () => {
        let talax = await TalaxToken.deployed();

        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        await helper.advanceTimeAndBlock(2 * 24 * 3600);
        await talax.changeTaxFee(2, { from: accounts[1] });

        let tax = await talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("Initial: cannot call 2 administrative functions under 48 hours", async () => {
        talax = await TalaxToken.deployed();

        thisAddress = await talax.thisAddress();
        let balance = await talax.balanceOf(thisAddress);
        console.log("Balance: ", balance.toString());

        try {
            await talax.mintLiquidityReserve(10000, { from: accounts[1] });
        } catch (err) {
            console.log(err.reason);
            assert.equal(
                err.reason,
                "Timelock: Administrative functions cannot be called in this TimeLock period (48 hours), please try again later.",
                "Failed to notice not Timelock functions"
            );
        }
    });

    it("Initial: cannot add beneficiary before initializing private sale", async () => {
        talax = await TalaxToken.deployed();

        try {
            await talax.addBeneficiary(accounts[5], 10000, { from: accounts[1] });
        } catch (err) {
            console.log(err.reason);
            assert.equal(
                err.reason,
                "Private Sale not yet started",
                "Failed to notice not Timelock functions"
            );
        }
    })

    it("Initial: status changed after initializing", async () => {
        talax = await TalaxToken.deployed();

        await talax.initiateLockedWallet_PrivateSale({ from: accounts[1] });
        let status = await talax.privateSaleStatus();

        assert.equal(status, true, "Status should be true");
    })
});
