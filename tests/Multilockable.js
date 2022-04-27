const TalaxToken = artifacts.require("TalaxToken");
const { assert } = require("chai");
const truffleAssert = require("truffle-assertions");
const helper = require("./helpers/truffleTestHelpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Multilockable", async (accounts) => {
    beforeEach(async () => {
        this.talax = await TalaxToken.deployed();
        this.owner = accounts[0];
        this.beneficiary = accounts[9];
    });

    it("Add new beneficiary", async () => {
        await this.talax.addBeneficiary(this.beneficiary, 10 * 1e6);

        let summary = await this.talax.hasMultilockable({
            from: this.beneficiary,
        });
        let estimatedGasFee = await this.talax.hasMultilockable.estimateGas({
            from: this.beneficiary,
        });
        console.log("Summary : ", summary);
        console.log("Estimated Gas Fee", estimatedGasFee);
        console.log("---------------------------------");
    });

    it("First claim", async () => {
        await helper.advanceTimeAndBlock(10 * 30 * 24 * 3600);
        await this.talax.claimPrivateSale({ from: this.beneficiary });

        balance = await this.talax.balanceOf(this.beneficiary);
        console.log("Balance : ", balance.toString());

        let summary = await this.talax.hasMultilockable({
            from: this.beneficiary,
        });
        let estimatedGasFee = await this.talax.hasMultilockable.estimateGas({
            from: this.beneficiary,
        });
        console.log("Summary : ", summary);
        console.log("Estimated Gas Fee", estimatedGasFee);
        console.log("---------------------------------");
    });

    it("First claim on the 20th month", async () => {
        await helper.advanceTimeAndBlock(10 * 30 * 24 * 3600);
        await this.talax.claimPrivateSale({ from: this.beneficiary });

        balance = await this.talax.balanceOf(this.beneficiary);
        console.log("Balance : ", balance.toString());

        let summary = await this.talax.hasMultilockable({
            from: this.beneficiary,
        });
        let estimatedGasFee = await this.talax.hasMultilockable.estimateGas({
            from: this.beneficiary,
        });
        console.log("Summary : ", summary);
        console.log("Estimated Gas Fee", estimatedGasFee);
        console.log("---------------------------------");
    });

    it("Add new beneficiary - 2", async () => {
        let beneficiary_2 = accounts[8];
        await this.talax.addBeneficiary(beneficiary_2, 20 * 1e6);
        await this.talax.claimPrivateSale({ from: beneficiary_2 });

        let summary = await this.talax.hasMultilockable({
            from: beneficiary_2,
        });
        let estimatedGasFee = await this.talax.hasMultilockable.estimateGas({
            from: beneficiary_2,
        });
        console.log("Summary : ", summary);
        console.log("Estimated Gas Fee", estimatedGasFee);
        console.log("---------------------------------");
    });
});
