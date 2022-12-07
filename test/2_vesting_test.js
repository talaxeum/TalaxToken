const { loadFixture, time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vesting contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Talaxeum");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const token = await Token.deploy();

        await token.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, token, owner, addr1, addr2 };
    }

    async function deployVestingFixture() {
        const Vesting = await ethers.getContractFactory("Vesting");

        const vesting = await Vesting.deploy();
        return { Vesting, vesting };
    }

    // it("Should assign the total supply of tokens to the owner", async function () {
    //     const { token, owner } = await loadFixture(deployTokenFixture);
    //     const ownerBalance = await token.balanceOf(owner.address);
    //     expect(await token.totalSupply()).to.equal(ownerBalance);
    // });

    // it("Should deploy the vesting contract correctly", async function () {
    //     const { vesting } = await loadFixture(deployVestingFixture);
    //     expect(await vesting.start()).to.equal(0);
    // });

    it("Should initialize the vesting contract correctly", async function () {
        const { token, addr1 } = await loadFixture(deployTokenFixture);
        const { vesting } = await loadFixture(deployVestingFixture);

        const start = 1670638556;
        const duration = 30 * 24 * 3600;
        const cliff = 5 * 24 * 3600;
        await vesting.init(token.address, addr1.address, start, duration, cliff);

        expect(await vesting.start()).to.equal(start + cliff);
    });

    it("Should release the correct amount to beneficiary", async function () {
        const { token, owner, addr1 } = await loadFixture(deployTokenFixture);
        const { vesting } = await loadFixture(deployVestingFixture);

        const start = 1670638556;
        const duration = 60 * 24 * 3600;
        const cliff = 5 * 24 * 3600;

        await token.transfer(vesting.address, 20 * 10e6);
        await vesting.init(token.address, addr1.address, start, duration, cliff);

        await time.increaseTo(1670638556 + 35 * 24 * 3600);
        await vesting.release();

        const balance = await token.balanceOf(addr1.address);
        // console.log(balance);
        const amount = 20 * 10e6 * 0.99 * 0.5 * 0.99;
        expect(balance).to.equal(ethers.BigNumber.from(amount));
    });
});
