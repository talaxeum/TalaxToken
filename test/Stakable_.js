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

contract("Stakable_", async (accounts) => {
    it("Staking 100x2", async () => {
		talax = await TalaxToken.deployed();
		supply = await talax.totalSupply();

        //? Stake 100 is used to stake 100 tokens twice and see that stake is added correctly and money burned
		let owner = accounts[0];
		let stake_amount = 10 * 1e3;
		balance = await talax.balanceOf(owner);

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
});
