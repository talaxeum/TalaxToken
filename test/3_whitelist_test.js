const { loadFixture, time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Whitelist contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Talaxeum");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const token = await Token.deploy();

        await token.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, token, owner, addr1, addr2 };
    }

    async function deployWhitelistFixture() {
        const Whitelist = await ethers.getContractFactory("Whitelist");

        const whitelist = await Whitelist.deploy();
        return { Whitelist, whitelist };
    }

    // it("Should assign the total supply of tokens to the owner", async function () {
    //     const { token, owner } = await loadFixture(deployTokenFixture);
    //     const ownerBalance = await token.balanceOf(owner.address);
    //     expect(await token.totalSupply()).to.equal(ownerBalance);
    // });

    // it("Should deploy the whitelist contract correctly", async function () {
    //     const { whitelist } = await loadFixture(deployWhitelistFixture);
    //     expect(await whitelist.start()).to.equal(0);
    // });

    it("Should initialize the whitelist contract correctly", async function () {
        const { token } = await loadFixture(deployTokenFixture);
        const { whitelist } = await loadFixture(deployWhitelistFixture);

        const start = 1670638556;
        const duration = 30 * 24 * 3600;
        const cliff = 5 * 24 * 3600;
        await whitelist.init(token.address, start, duration, cliff);

        expect(await whitelist.start()).to.equal(start + cliff);
    });

    it("Should add beneficiaries correctly", async function () {
        const { token, addr1, addr2 } = await loadFixture(deployTokenFixture);
        const { whitelist } = await loadFixture(deployWhitelistFixture);
        const beneficiaries = [
            { user: addr1.address, amount: 10 * 1e6 },
            { user: addr2.address, amount: 10 * 1e6 },
        ];

        const start = 1670811356;
        const duration = 60 * 24 * 3600;
        const cliff = 5 * 24 * 3600;
        await whitelist.init(token.address, start, duration, cliff);

        await whitelist.addBeneficiaries(beneficiaries);
        expect(await whitelist.connect(addr1).vestedAmount(1670811356 + 6 * 24 * 3600)).to.greaterThan(
            ethers.BigNumber.from(0)
        );
    });

    it("Should delete beneficiaries correctly", async function () {
        const { token, addr1, addr2 } = await loadFixture(deployTokenFixture);
        const { whitelist } = await loadFixture(deployWhitelistFixture);
        const beneficiaries = [
            { user: addr1.address, amount: 10 * 1e6 },
            { user: addr2.address, amount: 10 * 1e6 },
        ];

        const start = 1670811356;
        const duration = 60 * 24 * 3600;
        const cliff = 5 * 24 * 3600;
        await whitelist.init(token.address, start, duration, cliff);

        await whitelist.addBeneficiaries(beneficiaries);
        expect(await whitelist.connect(addr1).vestedAmount(1670811356 + 6 * 24 * 3600)).to.greaterThan(
            ethers.BigNumber.from(0)
        );

        await whitelist.deleteBeneficiaries([{ user: addr1.address, amount: 10 * 1e6 }]);
        expect(await whitelist.connect(addr1).vestedAmount(1670638556 + 5 * 24 * 3600)).to.equal(
            ethers.BigNumber.from(0)
        );
    });

    it("Should release token correctly", async function () {
        const { token, addr1, addr2 } = await loadFixture(deployTokenFixture);
        const { whitelist } = await loadFixture(deployWhitelistFixture);
        const beneficiaries = [
            { user: addr1.address, amount: 10 * 1e6 },
            { user: addr2.address, amount: 10 * 1e6 },
        ];

        const start = 1670811356;
        const duration = 60 * 24 * 3600;
        const cliff = 5 * 24 * 3600;

        await token.transfer(whitelist.address, 20 * 1e6);
        expect(await token.balanceOf(whitelist.address)).to.equal(ethers.BigNumber.from(20 * 1e6 * 0.99));

        await whitelist.init(token.address, start, duration, cliff);
        await whitelist.addBeneficiaries(beneficiaries);

        await time.increaseTo(start + 35 * 24 * 3600);

        await whitelist.connect(addr1).release();

        // console.log(balance);
        const amount = 10 * 1e6 * 0.99 * 0.5;
        // expect(await token.balanceOf(addr1.address)).to.equal(ethers.BigNumber.from(amount));
    });
});
