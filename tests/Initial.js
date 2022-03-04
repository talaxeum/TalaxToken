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
        console.log("Owners: ",owner);

        let init_owners = [
            "0x0Fa15f7550eC226C2a963f9cEB18aed8FD182075",
            "0x324505Aef2a89cd458824d4Fa225010329fd949A",
            "0xa9a58CF0a08B26FC832935870A329C99968f8Ec9"
        ];

        assert.equal(
            init_owners,
            owner,
            "Owner should be the one who deployed the contract"
        );
    });

    it("Initial: transfer owner", async () => {
        let talax = await TalaxToken.deployed();
        owner = await talax.getOwner();
        console.log("Owners: ", owner);

        let newOwners = [accounts[1], accounts[2]];

        await talax.transferOwnership(newOwners, {from: accounts[1]});
        await talax.transferOwnership(newOwners, {from: accounts[2]});
        await talax.transferOwnership(newOwners, {from: accounts[3]});

        owner = await talax.getOwner();
        console.log("Owners: ", owner);
    });

    it("Initial: change tax fee from not owner", async () => {
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

        await talax.changeTaxFee(2, { from: accounts[2] });

        let tax = await talax.taxFee();
        console.log("Tax: ", tax.toString());
    });

    it("Initial: mint", async () => {
        talax = await TalaxToken.deployed();

        thisAddress = await talax.thisAddress();
        let balance = await talax.balanceOf(thisAddress);
        console.log("Balance: ", balance.toString());

        await talax.mintLiquidityReserve(100000, {
            from: accounts[1],
        });
        await talax.mintLiquidityReserve(100000, {
            from: accounts[2],
        });

        balance = await talax.balanceOf(thisAddress);
        console.log("Balance: ", balance.toString());
    });

    it("Initial: burn", async () => {
        talax = await TalaxToken.deployed();

        let stakingreward = await talax.stakingReward();
        console.log("Start: ", stakingreward.toString());

        await talax.burnStakingReward(100000, {
            from: accounts[1],
        });
        await talax.burnStakingReward(100000, {
            from: accounts[2],
        });

        stakingreward = await talax.stakingReward();
        console.log("Start: ", stakingreward.toString());
    });
});
