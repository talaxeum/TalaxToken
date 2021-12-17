const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Stakable", async (accounts) => {
	it("Staking 100x2", async () => {
		talax = await TalaxToken.deployed();

		// Stake 100 is used to stake 100 tokens twice and see that stake is added correctly and money burned
		let owner = accounts[0];
		// Set owner, user and a stake_amount
		let stake_amount = 100;
		// Add som tokens on account 1 asweel
		await talax.increaseAllowance(accounts[1], 2000, { from: accounts[0] });
		await talax.transfer(accounts[1], 1000, {
			from: accounts[0],
		});
		let balance = await talax.balanceOf(accounts[1]);
		// Get init balance of user
		balance = await talax.balanceOf(owner);

		// Stake the amount, notice the FROM parameter which specifes what the msg.sender address will be

		stakeID = await talax.stake(stake_amount, {
			from: owner,
		});
		// Stake again on owner because we want hasStake test to assert summary
		stakeID = await talax.stake(stake_amount, {
			from: owner,
		});
		// Assert on the emittedevent using truffleassert
		// This will capture the event and inside the event callback we can use assert on the values returned
		truffleAssert.eventEmitted(
			stakeID,
			"Staked",
			(ev) => {
				// console.log(ev.amount.toString());
				// In here we can do our assertion on the ev variable (its the event and will contain the values we emitted)
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

	it("cannot stake more than owning", async () => {
		// Stake too much on accounts[2]
		talax = await TalaxToken.deployed();

		try {
			await talax.stake(1000000000, { from: accounts[2] });
		} catch (error) {
			assert.equal(
				error.reason,
				"TalaxToken: Cannot stake more than you own"
			);
		}
	});

	it("new stakeholder should have increased index", async () => {
		let stake_amount = 100;
		talax = await TalaxToken.deployed();
		stakeID = await talax.stake(stake_amount, { from: accounts[1] });

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

	it("cant withdraw bigger amount than current stake", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];

		// Try withdrawing 200 from first stake
		try {
			await talax.withdrawStake(200, 0, { from: owner });
		} catch (error) {
			// console.log(error.reason);
			assert.equal(
				error.reason,
				"Staking: Cannot withdraw more than you have staked",
				"Failed to notice a too big withdrawal from stake"
			);
		}
	});

	it("withdraw 50 from stake", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];
		let withdraw_amount = 50;

		await talax.withdrawStake(withdraw_amount, 0, { from: owner });
		let summary = await talax.hasStake(owner);

		// console.log(summary);

		assert.equal(
			summary.total_amount,
			200 - withdraw_amount,
			"The total staking amount should be 150"
		);
		let stake_amount = summary.stakes[0].amount;

		assert.equal(
			stake_amount,
			100 - withdraw_amount,
			"Wrong amount in first stake after withdrawal"
		);
	});

	it("remove stake if empty", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];
		let withdraw_amount = 50;

		await talax.withdrawStake(withdraw_amount, 0, { from: owner });
		let summary = await talax.hasStake(owner);
		// console.log(summary);

		assert.equal(
			summary.stakes[0].user,
			"0x0000000000000000000000000000000000000000",
			"Failed to remove stake when it was empty"
		);
	});

	it("calculate rewards", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];

		const newBlock = await helper.advanceTimeAndBlock(3600 * 20);
		let summary = await talax.hasStake(owner);

		let stake = summary.stakes[1];
		assert.equal(
			stake.claimable,
			100 * 0.02,
			"Reward should be 2 after staking 100 for 20 hours"
		);

		await talax.stake(1000, { from: owner });
		await helper.advanceTimeAndBlock(3600 * 20);

		summary = await talax.hasStake(owner);
		stake = summary.stakes[1];
		let newStake = summary.stakes[2];

		assert.equal(
			stake.claimable,
			100 * 0.04,
			"Reward should be 4 after staking for 40 hours"
		);
		assert.equal(
			newStake.claimable,
			1000 * 0.02,
			"Reward should be 20 after staking 20 hours"
		);
	});

	it("reward stakes", async () => {
		talax = await TalaxToken.deployed();

		let staker = accounts[3];
		await talax.increaseAllowance(accounts[3], 1000, { from: accounts[0] });
		await talax.transfer(accounts[3], 1000, {
			from: accounts[0],
		});
		let initial_balance = await talax.balanceOf(staker);

		await talax.stake(200, { from: staker });
		await helper.advanceTimeAndBlock(3600 * 20);

		let stakeSummary = await talax.hasStake(staker);
		let stake = stakeSummary.stakes[0];
		await talax.withdrawStake(100, 0, { from: staker });

		let after_balance = await talax.balanceOf(staker);
		let expected = 1000 - 200 + 100 + Number(stake.claimable); //? balance - stake + withdrawstake + stake reward
		assert.equal(
			after_balance.toNumber(),
			expected,
			"Failed to withdraw the stakes correctly"
		);

		try {
			await talax.withdrawStake(100, 0, { from: staker });
		} catch (error) {
			assert.fail(error);
		}

		let second_balance = await talax.balanceOf(staker);
		assert.equal(
			second_balance.toNumber(),
			after_balance.toNumber() + 100,
			"Failed to reset timer second withdrawal reward"
		);
	});
});
