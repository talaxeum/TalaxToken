const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Multilock", async (accounts) => {
    let talax;
    let owner = accounts[0];
    before(async () => {
        talax = await TalaxToken.deployed();
    });

    it("Multilock: add beneficiaries", async () => {
        try {
            await talax.initiateLockedWallet_PrivateSale_Airdrop({
                from: owner,
            });
        } catch (err) {
            console.error(err.reason);
        }

        benefs = [
            { user: accounts[1], amount: 10000 },
            { user: accounts[2], amount: 10000 },
            { user: accounts[3], amount: 10000 },
            { user: accounts[4], amount: 10000 },
            { user: accounts[5], amount: 10000 },
        ];

        try {
            await talax.addMultipleBeneficiary(benefs);
        } catch (err) {
            console.error("Multilock:", err.reason);
        }

        benefs2 = [{ user: accounts[1], amount: 10000 }];
        try {
            await talax.addMultipleBeneficiary(benefs2);
        } catch (err) {
            console.error("Multilock:", err.reason);
        }
    });

    it("Multilock: delete beneficiaries", async () => {
        benefs = [accounts[1], accounts[2], accounts[4]];

        try {
            await talax.deleteMultipleBeneficiary(benefs);
        } catch (err) {
            console.error(err.reason);
        }

        benefsLeft = await talax.privateSaleUsers();
        console.log("Private Sale users:", parseFloat(benefsLeft));
    });
});
