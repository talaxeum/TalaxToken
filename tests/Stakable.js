const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

/**
 * ? TEST CASES
 * * Staking 100x2
 * * Cannot Stake more than owned Token
 * * New Stakeholders should have increased index
 * * Can't withdraw amount bigger than current stake index
 * * Withdraw 5 * 1e3 from stake index
 * TODO: Remove stake if empty
 * TODO: Calculate claimable amount from stake index
 * TODO: Calculate rewards from stake index
 */

contract("Stakable", async (accounts) => {
    /**
     * ? Starting status
     * ? Balance :
     * * Owner : Total Supply
     * * acc1 : 0
     * * acc2 : 0
     * ? Staking :
     * * Owner : 0
     * * acc1 : 0
     * * acc2 : 0
     */

    it("Staking 100x2", async () => {
        talax = await TalaxToken.deployed();
        supply = await talax.totalSupply();

        //? Stake 100 is used to stake 100 tokens twice and see that stake is added correctly and money burned
        let owner = accounts[0];
        let stake_amount = 10 * 1e3;
        let balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        //? Stake the amount, notice the FROM parameter which specifes what the msg.sender address will be
        stakeID = await talax.stake(stake_amount, 30 * 24 * 3600, {
            from: owner,
        });
        //? Stake again on owner because we want hasStake test to assert summary
        stakeID = await talax.stake(stake_amount, 30 * 24 * 3600, {
            from: owner,
        });

        stake = await talax.stakeSummary(owner);

        summary = await talax.hasStake(owner);
        // console.log(summary.toString());

        //? Assert on the emittedEvent using truffleAssert
        //? This will capture the event and inside the event callback we can use assert on the values returned
        truffleAssert.eventEmitted(
            stakeID,
            "Staked",
            (ev) => {
                // console.log(ev.amount.toString());
                //? In here we can do our assertion on the ev variable (its the event and will contain the values we emitted)
                assert.equal(
                    ev.amount,
                    stake_amount,
                    "Stake amount in event was not correct"
                );
                assert.equal(ev.index, 1, "Stake index was not correct");
                return true;
            },
            "Stake event should have triggered"
        );
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - 20 * 1e3
     * * acc1 : 0
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [10 * 1e3, 10 * 1e3]
     * * acc1 : 0
     * * acc2 : 0
     */

    it("New stakeholder should have increased index", async () => {
        talax = await TalaxToken.deployed();

        let transferAmount = 100 * 1e3;
        let stake_amount = 10 * 1e3;

        await talax.transfer(accounts[1], transferAmount, {
            from: accounts[0],
        });

        let balance = await talax.balanceOf(accounts[1]);
        console.log(balance.toString());

        assert.equal(
            balance,
            transferAmount - 0.01 * transferAmount,
            "Transfer amount is not correct"
        );

        stakeID = await talax.stake(stake_amount, 30 * 24 * 3600, {
            from: accounts[1],
        });

        truffleAssert.eventEmitted(
            stakeID,
            "Staked",
            (ev) => {
                // console.log(ev);

                assert.equal(
                    ev.amount,
                    stake_amount,
                    "Stake amount in event was not correct"
                );
                assert.equal(ev.index, 2, "Stake index was not correct");
                return true;
            },
            "Stake event should have trigerred"
        );
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - (20 * 1e3) - (100 * 1e3)
     * * acc1 : (100 * 1e3) - (10 * 1e3)
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [10 * 1e3, 10 * 1e3, 0]
     * * acc1 : 1 [0, 0, 10 * 1e3]
     * * acc2 : 0
     */

    it("Cannot stake more than balance", async () => {
        talax = await TalaxToken.deployed();

        try {
            await talax.stake(10 * 1e3, 30 * 24 * 3600, { from: accounts[2] });
        } catch (err) {
            assert.equal(
                err.reason,
                "TalaxToken: Cannot stake more than balance"
            );
        }
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - (20 * 1e3) - (100 * 1e3)
     * * acc1 : (100 * 1e3) - (10 * 1e3)
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [10 * 1e3, 10 * 1e3, 0]
     * * acc1 : 1 [0, 0, 10 * 1e3]
     * * acc2 : 0
     */

    it("Cannot withdraw bigger amount than current stake index", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        //* Try withdrawing (20 * 1e3) from first stake
        try {
            await helper.advanceTimeAndBlock(3600 * 24 * 30);
            await talax.withdrawStake(20 * 1e3, 0, { from: owner });
        } catch (error) {
            assert.equal(
                error.reason,
                "Stakable: Cannot withdraw more than you have staked",
                "Failed to notice a too big withdrawal from stake"
            );
        }
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - (20 * 1e3) - (100 * 1e3)
     * * acc1 : (100 * 1e3) - (10 * 1e3)
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [10 * 1e3, 10 * 1e3, 0]
     * * acc1 : 1 [0, 0, 10 * 1e3]
     * * acc2 : 0
     */

    it("Withdraw 5 from stake", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];
        let withdraw_amount = 5 * 1e3;

        await helper.advanceTimeAndBlock(3600 * 24 * 30);

        balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        await talax.withdrawStake(withdraw_amount, 0, { from: owner });

        balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        let summary = await talax.hasStake(owner);
        console.log(summary.toString());

        assert.equal(
            summary.total_amount,
            20 * 1e3 - withdraw_amount,
            "The total staking amount should be 15"
        );

        let stake_amount = summary.stakes[0].amount;

        assert.equal(
            stake_amount,
            10 * 1e3 - withdraw_amount,
            "Wrong amount in first stake after withdrawal"
        );
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - (20 * 1e3) - (100 * 1e3) + (5 * 1e3)
     * * acc1 : (100 * 1e3) - (10 * 1e3)
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [5 * 1e3, 10 * 1e3]
     * * acc1 : 1 [10 * 1e3]
     * * acc2 : 0
     */

    it("Withdraw before designated time", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        let withdrawAmount = 1 * 1e3;

        await talax.withdrawStake(withdrawAmount, 0, { from: owner });

        let summary = await talax.hasStake(owner);

        assert.equal(
            summary.stakes[0].amount.toString(),
            "4000",
            "Amount is not 4000 after depletion"
        );
    });

    it("Remove stake if empty", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];
        let withdrawAmount = 4 * 1e3;

        await helper.advanceTimeAndBlock(3600 * 24 * 30);
        await talax.withdrawStake(withdrawAmount, 0, { from: owner });

        let summary = await talax.hasStake(owner);
        for (s = 0; s < summary.stakes.length; s++) {
            console.log(summary.stakes[s].toString());
        }

        assert.equal(
            summary.stakes[0].amount.toString(),
            "0",
            "Amount is not 0 after depletion"
        );
    });

    /**
     * ? Balance :
     * * Owner : Total Supply - (20 * 1e3) - (100 * 1e3) + (5 * 1e3) + (5 * 1e3)
     * * acc1 : (100 * 1e3) - (10 * 1e3)
     * * acc2 : 0
     * ? Staking :
     * * Owner : 2 [0, 10 * 1e3, 0]
     * * acc1 : 1 [0, 0, 10 * 1e3]
     * * acc2 : 0
     */

    it("Calculate claimable staking amount", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        let test = await talax.testCalculateDuration(owner, 1);
        console.log(test / (3600 * 24 * 30));

        let summary = await talax.hasStake(owner);
        for (s = 0; s < summary.stakes.length; s++) {
            console.log(summary.stakes[s]);
        }

        let stake = summary.stakes[1];

        let blocktime = await talax.blockTime();

        let duration = (blocktime - stake.since) / (3600 * 24 * 30 * 12);

        console.log("Stake Duration in Months :", duration);

        assert.equal(
            stake.claimable,
            Math.floor(10 * 1e3 * 0.05 * (90 / 365)),
            "Reward should be 123 after staking 10000 for 90 days"
        );
    });

    it("Calculate airdrop", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        let balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        await talax.claimAirdrop({ from: owner });

        balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        let summary = await talax.hasStake(owner);
        for (s = 0; s < summary.stakes.length; s++) {
            console.log(summary.stakes[s]);
        }
    });

    it("Cannot claim airdrop within the same month", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        try {
            await talax.claimAirdrop({ from: owner });
        } catch (error) {
            assert.equal(
                error.reason,
                "Stakable: Airdrop can only be claimed in a month timespan",
                "Failed to notice a airdrop error"
            );
        }
    });

    it("Calculate airdrop again", async () => {
        talax = await TalaxToken.deployed();

        let owner = accounts[0];

        let balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        await helper.advanceTimeAndBlock(3600 * 24 * 28);

        await talax.claimAirdrop({ from: owner });

        balance = await talax.balanceOf(owner);
        console.log(balance.toString());

        let summary = await talax.hasStake(owner);
        for (s = 0; s < summary.stakes.length; s++) {
            console.log(summary.stakes[s]);
        }
    });
});
