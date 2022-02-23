const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("TalaxToken", async (accounts) => {
    it("TalaxInitial: initial owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        assert.equal(
            accounts[0],
            owner,
            "Owner should be the one who deployed the contract"
        );
    });

    it("TalaxInitial: transfer owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        let newOwners = [accounts[1], accounts[2]];

        await talax.transferOwnership(newOwners);

        owner = await talax.getOwner();
        console.log("Owners: ", owner);
    });

    it("TalaxInitial: change tax fee from not owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log(owner);

        bool = await talax.isOwner(accounts[3]);
        console.log(bool);

        try {
            await talax.changeTaxFee(2, { from: accounts[3] });
        } catch (err) {
            console.log(err.reason);
            assert.equal(
                err.reason,
                "checkHowManyOwners: msg.sender is not an owner",
                "Failed to notice not owner validation"
            );
        }
    });

    it("TalaxInitial: change tax fee account 1", async () => {
        let talax = await TalaxToken.deployed();

        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        await talax.changeTaxFee(2, { from: accounts[1] });

        let tax = await talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("TalaxInitial: change tax fee account 2", async () => {
        let talax = await TalaxToken.deployed();

        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        await talax.changeTaxFee(2, { from: accounts[2] });

        let tax = await talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("TalaxInitial: mint", async () => {
        talax = await TalaxToken.deployed();

    });

    it("TalaxInitial: burn", async () => {
        talax = await TalaxToken.deployed();
        
    });

});
