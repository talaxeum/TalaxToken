const assert = require("assert");

const TalaxToken = artifacts.require("TalaxToken");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("TalaxToken", async (accounts) => {
	it("initial supply", async () => {
		let talax = await TalaxToken.deployed();
		let supply = await talax.totalSupply();
		assert.equal(21000000000, supply, "Supply should be 21 Billion Talax");
	});

	it("initial owner", async () => {
		let talax = await TalaxToken.deployed();
		owner = await talax.getOwner();
		assert.equal(
			accounts[0],
			owner,
			"Owner should be the one who deployed the contract"
		);
	});
});
