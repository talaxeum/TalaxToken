const TalaxToken = artifacts.require("TalaxToken");
const Multilockable = artifacts.require("Multilockable");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Multilockable", async (accounts) => {
    it("Add new beneficiary", async () => {
        talax = await TalaxToken.deployed();
        owner = accounts[0];

        beneficiary = accounts[9];
        await talax.addBeneficiary(beneficiary, 10 * 1e6);

        let summary = await talax.hasMultilockable({ from: beneficiary });
        console.log(summary);
        // let balance = await web3.eth.getBalance(owner);
        // console.log(balance.toString());
    });

    it("First claim", async () => {
        talax = await TalaxToken.deployed();
        beneficiary = accounts[9];
    });

    it("First claim on the 16th month", async () => {
        talax = await TalaxToken.deployed();
        beneficiary = accounts[9];
    });
});