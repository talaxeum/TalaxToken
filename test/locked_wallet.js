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

	it("not yet claimable", async () => {
		talax = await TalaxToken.deployed();
		owner = accounts[3];

		try {
			await talax.unlockDevPoolWallet({ from: owner });
		} catch (error) {
			console.log(error.reason);
			assert.equal(
				error.reason,
				"TokenTimeLock: There's nothing to claim yet",
				"Failed to notice a 0 withdrawal from DevPool"
			);
		}

		balance = await talax.balanceOf(owner);
	});

	it("wrong owner claim", async () => {
		talax = await TalaxToken.deployed();
		owner = accounts[1];

		try {
			await talax.unlockDevPoolWallet({ from: owner });
		} catch (error) {
			console.log(error.reason);
			assert.equal(
				error.reason,
				"TokenTimeLock: Only claimable by User of this address or owner",
				"Failed to notice wrong owner claim from DevPool"
			);
		}
	});

	it("claim after the designated time", async () => {
		talax = await TalaxToken.deployed();
		owner = accounts[3]
		
		await helper.advanceTimeAndBlock(3600 * 24 * 30);

		let balance = await talax.balanceOf(owner);
		console.log(balance.toString());

		await talax.unlockDevPoolWallet({from:owner});
		balance = await talax.balanceOf(owner);
		console.log(balance.toString());
	});
});
