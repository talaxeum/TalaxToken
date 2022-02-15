const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");
const BigNumber = require("bignumber.js");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("TalaxToken", async (accounts) => {
    it("MultiLockable: Try to claim without adding user", async () => {
        talax = await TalaxToken.deployed();
        let owner = accounts[0];

        try {
            await talax.releasePrivatePlacement({ from: owner });
        } catch (error) {
            console.log(error.reason);
            assert.equal(
                error.reason,
                "MultiTokenTimeLock: User doesn't exist",
                "Failed to notice zero amount of locked wallet"
            );
        }
    });

    it("MultiLockable: Add user", async () => {
        talax = await TalaxToken.deployed();
        let user = accounts[4];
        let owner = accounts[0];

        await talax.addPrivatePlacementUser(
            user,
            new BigNumber(1 * 1e6 * 1e18),
            { from: owner }
        );

        // amount = await talax.privatePlacementAmount({ from: owner });
        // index = await talax.privatePlacementIndex({ from: owner });
        // console.log(amount.toString(), index.toString());
    });

    it("MultiLockable: Try to claim before the designated time", async () => {
        talax = await TalaxToken.deployed();
        let user = accounts[4];

        let balance = await talax.balanceOf(user);

        try {
            await helper.advanceTimeAndBlock(3600 * 24 * 30);
            await talax.releasePrivatePlacement({ from: user });
        } catch (error) {
            console.log(error.reason);
            assert.equal(
                error.reason,
                "MultiTokenTimeLock: There's nothing to claim yet",
                "Failed to notice zero amount of locked wallet"
            );
        }

        balance = await talax.balanceOf(user);
        console.log(balance.toString());
    });

    it("MultiLockable: Try to claim locked wallet", async () => {
        talax = await TalaxToken.deployed();
        let user = accounts[4];

        await helper.advanceTimeAndBlock(3600 * 24 * 30 * 7);
        await talax.releasePrivatePlacement({ from: user });

        // amount = await talax.privatePlacementAmount({ from: owner });
        // month = await talax.privatePlacementMonth({ from: owner });
        // duration = await talax.privatePlacementDuration({ from: owner });
        // console.log("Second", amount.toString(), month.toString(), duration.toString());
        // assert.equal(month, 8, "Month should be 8");

        balance = await talax.balanceOf(user);
        console.log(balance.toString());
    });
});
