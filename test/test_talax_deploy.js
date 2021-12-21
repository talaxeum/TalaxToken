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
	it("initial supply", async () => {
		let talax = await TalaxToken.deployed();
		let supply = await talax.totalSupply();
		// console.log(supply.toString());
		assert.equal(0, supply, "Supply should be 210 Million Talax");
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

	it("initial staking package", async () => {
		let talax = await TalaxToken.deployed();
		let package = await talax.stakingPackage(2.592e6);
		// console.log(package.toString());
		assert.equal(5, package, "Supply should be 5 %");
		package = await talax.stakingPackage(15.552e6);
		// console.log(package.toString());
		assert.equal(7, package, "Supply should be 7 %");
	});

	it("initial tax fee", async () => {
		let talax = await TalaxToken.deployed();
		let tax = await talax.taxFee();
		// console.log(tax.toString());
		assert.equal(1, tax, "Supply should be 5 %");
	});
});
