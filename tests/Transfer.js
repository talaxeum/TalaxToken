const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/**
 * ? TEST CASES
 * * Simple Transfer
 * * Transfer to 0 Address
 * * Transfer without approval
 */

contract("Transfer", async (accounts) => {
    it("Simple Transfer", async () => {
        talax = await TalaxToken.deployed();

        supply = await talax.totalSupply.call();
        console.log("simple transfer (totalSupply): ", supply.toString());

        let owner = accounts[0];
        let target = accounts[1];

        /**
         * Start Balance
         */

        let ownerStartBalance = await talax.balanceOf(owner);
        let targetStartBalance = await talax.balanceOf(target);

        console.log(
            "Simple transfer (ownerStartBalance)",
            ownerStartBalance.toString()
        );
        console.log(
            "Simple transfer (targetStartBalance)",
            targetStartBalance.toString()
        );

        /**
         * Calling Transfer Function
         */

        let transferAmount = 1e15;
        let transferID = await talax.transfer(target, transferAmount, {
            from: owner,
        });

        truffleAssert.eventEmitted(
            transferID,
            "Transfer",
            (ev) => {
                assert.equal(
                    ev.value,
                    transferAmount - 0.01 * transferAmount,
                    "Transfer amount was not correct"
                );
                return true;
            },
            "Transfer event should have been trigerred"
        );

        /**
         * End Balance
         */

        let ownerEndBalance = await talax.balanceOf(owner);
        let targetEndBalance = await talax.balanceOf(target);

        console.log(
            "Simple transfer (ownerEndBalance)",
            ownerEndBalance.toString()
        );
        console.log(
            "Simple transfer (targetEndBalance)",
            targetEndBalance.toString()
        );
    });

    it("Transfer to 0 address", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];
        let target = accounts[1];

        /**
         * Check Balance
         */

        let ownerBalance = await talax.balanceOf(owner);
        let targetBalance = await talax.balanceOf(target);

        console.log(
            "Transfer to 0 address (ownerStartBalance)",
            ownerBalance.toString()
        );
        console.log(
            "Transfer to 0 address (targetStartBalance)",
            targetBalance.toString()
        );

        let transferAmount = 1e15;

        try {
            await talax.transfer(
                "0x0000000000000000000000000000000000000000",
                transferAmount
            );
        } catch (err) {
            assert.equal(
                err.reason,
                "TalaxToken: transfer to the zero address"
            );
        }
    });

    it("Transfer without approval", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];
        let target = accounts[1];

        /**
         * Check Balance
         */

        let ownerBalance = await talax.balanceOf.call(owner);
        let targetBalance = await talax.balanceOf.call(target);

        console.log(
            "Transfer without approval (ownerStartBalance)",
            ownerBalance.toString()
        );
        console.log(
            "Transfer without approval (targetStartBalance)",
            targetBalance.toString()
        );

        let transferAmount = 1e15;

        try {
            await talax.transferFrom(owner, target, transferAmount, {
                from: target,
            });
        } catch (err) {
            assert.equal(
                err.reason,
                "TalaxToken: transfer amount exceeds allowance"
            );
        }

        /**
         * End Balance
         */

        let ownerEndBalance = await talax.balanceOf(owner);
        let targetEndBalance = await talax.balanceOf(target);

        console.log(
            "Transfer without approval (ownerEndBalance)",
            ownerEndBalance.toString()
        );
        console.log(
            "Transfer without approval (targetEndBalance)",
            targetEndBalance.toString()
        );
    });
});
