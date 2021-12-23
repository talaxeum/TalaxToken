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

contract("TalaxToken", async accounts => {
	it("initial timelocked", async () => {
		talax = await TalaxToken.deployed();
		devPool = await talax.devPool();
		stratPartner = await talax.stratPartner();
		privatePlacement = await talax.privatePlacement();
		teamAndProject = await talax.teamAndProject();
		console.log(devPool);
		console.log(stratPartner);
		console.log(privatePlacement);
		console.log(teamAndProject);
		// assert.equal(0, supply, "Supply should be 210 Million Talax");
	});

	it("try to claim without adding user", async () => {
		talax = await TalaxToken.deployed();
		let user = accounts[0];

		// let balance = await talax.balanceOf(accounts[0]);
		// console.log(balance.toString());
		// rate = await talax.privatePlacementRate();
		// console.log(rate.length);
		// for(i = 0; i < rate.length; i++){
		// 	console.log((new BigNumber(rate[i])).toFixed())
		// }

		try {
			await helper.advanceTimeAndBlock(3600 * 24 * 120);

			// let duration = await talax.privatePlacementDuration({ from: user });
			// console.log(duration.toString());
			

			await talax.releasePrivatePlacement({ from: user });
		} catch (error) {
			console.log(error.reason);
			assert.equal(
				error.reason,
				"MultiTokenTimeLock: User doesn't exist",
				"Failed to notice zero amount of locked wallet"
			);
		}

		balance = await talax.balanceOf(accounts[0]);
		console.log(balance.toString());
	});

	it("add user", async () => {
		talax = await TalaxToken.deployed();
		let owner = accounts[4];

		await talax.addPrivatePlacementUser(
			owner,
			new BigNumber(1 * 1e6 * 10 ** 18),
			{ from: accounts[0] }
		);

		amount = await talax.privatePlacementAmount({ from: owner });
		index = await talax.privatePlacementIndex({ from: owner });
		console.log(amount.toString(), index.toString());
	});

	it("try to claim before the designated time", async () => {
		talax = await TalaxToken.deployed();
		let owner = accounts[4];


		let balance = await talax.balanceOf(owner);
		amount = await talax.privatePlacementAmount({ from: owner });
		index = await talax.privatePlacementIndex({ from: owner });
		console.log(amount.toString(), index.toString());

		try {
			await helper.advanceTimeAndBlock(3600 * 24 * 10);
			await talax.releasePrivatePlacement({ from: owner });
		} catch (error) {
			console.log(error.reason);
			assert.equal(
				error.reason,
				"MultiTokenTimeLock: There's nothing to claim yet",
				"Failed to notice zero amount of locked wallet"
			);
		}

		balance = await talax.balanceOf(owner);
		console.log(balance.toString());
	});

	it("try to claim locked wallet", async () => {
		talax = await TalaxToken.deployed();
		let owner = accounts[4];

		amount = await talax.privatePlacementAmount({ from: owner });
		month = await talax.privatePlacementMonth({ from: owner });
		duration = await talax.privatePlacementDuration({ from: owner });
		console.log("First", amount.toString(), month.toString(), duration.toString());

		// console.log(await talax.privatePlacementRate());
		// rate = await talax.privatePlacementRate();
		// console.log(rate.length);
		// for(i = 0; i < rate.length; i++){
		// 	console.log((new BigNumber(rate[i])).toFixed())
		// }

		await helper.advanceTimeAndBlock(3600 * 24 * 210);
		await talax.releasePrivatePlacement({ from: owner });

		amount = await talax.privatePlacementAmount({ from: owner });
		month = await talax.privatePlacementMonth({ from: owner });
		duration = await talax.privatePlacementDuration({ from: owner });
		console.log("Second", amount.toString(), month.toString(), duration.toString());
		assert.equal(month, 7, "Month should be 8");

		balance = await talax.balanceOf(owner);
		console.log(balance.toString());
	});
});
