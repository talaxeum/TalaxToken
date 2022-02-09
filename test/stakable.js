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
 * ! Remove stake if empty
 * ! Calculate claimable amount from stake index
 * ! Calculate rewards from stake index
*/

contract("Stakable", async (accounts) => {
	it("Staking 100x2", async () => {
		talax = await TalaxToken.deployed();
		supply = await talax.totalSupply();
		// console.log(supply.toString());
		// Stake 100 is used to stake 100 tokens twice and see that stake is added correctly and money burned
		let owner = accounts[0];
		// Set owner, user and a stake_amount
		let stake_amount = 10 * 1e3;
		// Add som tokens on account 1 asweel
		await talax.increaseAllowance(accounts[1], 2000, { from: owner });
		await talax.transfer(accounts[1], 1000, {
			from: owner,
		});
		let balance = await talax.balanceOf(accounts[1]);
		// Get init balance of user
		balance = await talax.balanceOf(owner);
		// console.log(balance.toString());

		// Stake the amount, notice the FROM parameter which specifes what the msg.sender address will be

		stakeID = await talax.stake(stake_amount, 2592 * 1e3, {
			from: owner,
		});
		// Stake again on owner because we want hasStake test to assert summary
		stakeID = await talax.stake(stake_amount, 2592 * 1e3, {
			from: owner,
		});

		stake = await talax.stakeSummary(owner);
		// amountStake = await talax.stakeAmount(stake);
		// apyStake = await talax.stakeAPY(stake);
		// sinceStake = await talax.stakeSince(stake);
		// console.log(stake.toString());

		summary = await talax.hasStake(owner);
		// console.log(summary.toString());
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
			await talax.stake(1000000000, 2.592e6, { from: accounts[2] });
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
		stakeID = await talax.stake(stake_amount, 2.592e6, {
			from: accounts[1],
		});

		// summary = await talax.hasStake(accounts[1]);
		// console.log(summary.toString());

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

	it("can't withdraw bigger amount than current stake index", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];

		// Try withdrawing 200 from first stake
		try {
			await helper.advanceTimeAndBlock(3600 * 24 * 30);
			await talax.withdrawStake(20 * 1e3, 0, { from: owner });
		} catch (error) {
			// console.log(error.reason);
			assert.equal(
				error.reason,
				"Staking: Cannot withdraw more than you have staked",
				"Failed to notice a too big withdrawal from stake"
			);
		}
	});

	// it("withdraw 50 from stake test", async () => {
	// 	talax = await TalaxToken.deployed();

	// 	try{
	// 		summary = await talax.hasStake(accounts[0]);
	// 		console.log(summary.toString());
	// 	} catch(error){
	// 		console.log(error);
	// 	}
	// });

	it("withdraw 5 from stake", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];
		let withdraw_amount = 5 * 1e3;

		let summary = await talax.hasStake(owner);
		// console.log(summary.toString());

		await talax.withdrawStake(withdraw_amount, 0, { from: owner });

		summary = await talax.hasStake(owner);
		// console.log(summary);

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

	it("remove stake if empty", async () => {
		talax = await TalaxToken.deployed();

		let owner = accounts[0];

		await helper.advanceTimeAndBlock(3600 * 24 * 32);

		let summary = await talax.hasStake(owner);
		console.log(summary);

		await talax.withdrawAllStake(0, { from: owner });

		summary = await talax.hasStake(owner);
		console.log(summary);

		assert.equal(
			summary.stakes[0].user,
			"0x0000000000000000000000000000000000000000",
			"Failed to remove stake when it was empty"
		);
	});

	// it("calculate claimable staking amount", async () => {
	// 	talax = await TalaxToken.deployed();

	// 	const owner = accounts[0];
	// 	stakeID = await talax.stake(200, 2.592e6, { from: owner });

	// 	summary = await talax.hasStake(owner);
	// 	// console.log(summary.toString());

	// 	stake = summary.stakes[1];
	// 	// console.log(stake.toString());
	// 	// console.log(stake.amount.toString());
	// 	// console.log(stake.claimable.toString());
	// 	assert.equal(
	// 		stake.claimable,
	// 		(500 * 0.05) / 12,
	// 		"Reward should be 0.416 after staking 100 for 30 days"
	// 	);

	// 	await talax.stake(1000, { from: owner });
	// 	await helper.advanceTimeAndBlock(3600 * 20);

	// 	summary = await talax.hasStake(owner);
	// 	stake = summary.stakes[1];
	// 	let newStake = summary.stakes[2];

	// 	assert.equal(
	// 		stake.claimable,
	// 		100 * 0.04,
	// 		"Reward should be 4 after staking for 40 hours"
	// 	);
	// 	assert.equal(
	// 		newStake.claimable,
	// 		1000 * 0.02,
	// 		"Reward should be 20 after staking 20 hours"
	// 	);
	// });

	// it("reward stakes", async () => {
	// 	talax = await TalaxToken.deployed();

	// 	let staker = accounts[3];
	// 	await talax.increaseAllowance(accounts[3], 1000, { from: accounts[0] });
	// 	await talax.transfer(accounts[3], 1000, {
	// 		from: accounts[0],
	// 	});
	// 	let initial_balance = await talax.balanceOf(staker);

	// 	await talax.stake(200, 2.592e6, { from: staker });
	// 	await helper.advanceTimeAndBlock(3600 * 20);

	// 	let stakeSummary = await talax.hasStake(staker);
	// 	let stake = stakeSummary.stakes[0];
	// 	await talax.withdrawStake(100, 0, { from: staker });

	// 	let after_balance = await talax.balanceOf(staker);
	// 	let expected = 1000 - 200 + 100 + Number(stake.claimable); //? balance - stake + withdrawstake + stake reward
	// 	assert.equal(
	// 		after_balance.toNumber(),
	// 		expected,
	// 		"Failed to withdraw the stakes correctly"
	// 	);

	// 	try {
	// 		await talax.withdrawStake(100, 0, { from: staker });
	// 	} catch (error) {
	// 		assert.fail(error);
	// 	}

	// 	let second_balance = await talax.balanceOf(staker);
	// 	assert.equal(
	// 		second_balance.toNumber(),
	// 		after_balance.toNumber() + 100,
	// 		"Failed to reset timer second withdrawal reward"
	// 	);
	// });
});
