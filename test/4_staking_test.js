const { loadFixture, time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Talaxeum");
        const Staking = await ethers.getContractFactory("Staking");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const token = await Token.deploy();
        await token.deployed();

        const staking = await Staking.deploy(token.address);
        await staking.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, token, staking, owner, addr1, addr2 };
    }

    it("Should stake successfully", async function () {
        const { token, staking } = await loadFixture(deployTokenFixture);
        const duration = 90 * 24 * 3600;

        await token.approve(staking.address, ethers.utils.parseEther("100"));
        await staking.stake(ethers.utils.parseEther("100"), duration);
        const stakes = await staking.hasStake();
        expect(stakes.total_amount).to.equal(ethers.utils.parseEther("99"));
    });

    it("Should withdraw with penalty successfully", async function () {
        const { token, staking, owner, addr1 } = await loadFixture(deployTokenFixture);
        const duration = 90 * 24 * 3600;

        await token.transfer(addr1.address, ethers.utils.parseEther("200"));

        await token.connect(addr1).approve(staking.address, ethers.utils.parseEther("100"));
        await staking.connect(addr1).stake(ethers.utils.parseEther("100"), duration);
        const stakes = await staking.connect(addr1).hasStake();
        expect(stakes.total_amount).to.equal(ethers.utils.parseEther("99"));

        await time.increase(30 * 24 * 3600);

        await staking.connect(addr1).withdrawStake();
        const reward = (99 * 0.06) / 12; // 6% APY
        const penalty = 99 * 0.015 + reward * 0.015; // 1.5% Penalty Rate
        const withdrawAmount = 99 + reward - penalty;

        const balance = (98 + withdrawAmount * 0.99).toString();

        expect(await token.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther(balance));
    });

    it("Should withdraw successfully", async function () {
        const { token, staking, owner, addr1 } = await loadFixture(deployTokenFixture);
        const duration = 90 * 24 * 3600;

        await token.transfer(staking.address, ethers.utils.parseEther("1000000"));
        await token.transfer(addr1.address, ethers.utils.parseEther("200"));

        await token.connect(addr1).approve(staking.address, ethers.utils.parseEther("100"));
        await staking.connect(addr1).stake(ethers.utils.parseEther("100"), duration);
        const stakes = await staking.connect(addr1).hasStake();
        expect(stakes.total_amount).to.equal(ethers.utils.parseEther("99"));

        await time.increase(90 * 24 * 3600);

        await staking.connect(addr1).withdrawStake();
        const reward = ((99 * 0.06) / 12) * 3; // 6% APY
        const withdrawAmount = 99 + reward;

        const balance = (98 + withdrawAmount * 0.99).toString();

        expect(await token.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther(balance));
    });

    it("Should failed change penalty successfully", async function () {
        const { token, staking, addr1 } = await loadFixture(deployTokenFixture);

        await expect(staking.connect(addr1).changePenaltyFee(20)).to.be.revertedWith(
            "Ownable: caller is not the owner"
        );
    });
    it("Should change penalty successfully", async function () {
        const { staking } = await loadFixture(deployTokenFixture);

        await staking.changePenaltyFee(20);

        expect(await staking.stakingPenaltyRate()).to.equal(20);
    });

    it("Should fail to initialize airdrop successfully", async function () {
        const { staking, addr1 } = await loadFixture(deployTokenFixture);

        await expect(staking.connect(addr1).startAirdrop()).to.be.revertedWith("Ownable: caller is not the owner");
    });
    it("Should initialize airdrop successfully", async function () {
        const { staking, addr1 } = await loadFixture(deployTokenFixture);

        await staking.startAirdrop();

        expect(await staking.airdropStatus()).to.equal(true);
    });

    it("Should failed change airdrop rate successfully", async function () {
        const { token, staking, addr1 } = await loadFixture(deployTokenFixture);

        await expect(staking.connect(addr1).changeAirdropPercentage(100)).to.be.revertedWith(
            "Ownable: caller is not the owner"
        );
    });
    it("Should change airdrop rate successfully", async function () {
        const { staking } = await loadFixture(deployTokenFixture);

        await staking.changeAirdropPercentage(100);

        expect(await staking.airdropRate()).to.equal(100);
    });

    it("Should fail to claim airdrop successfully", async function () {
        const { token, staking } = await loadFixture(deployTokenFixture);
        const duration = 90 * 24 * 3600;

        await token.approve(staking.address, ethers.utils.parseEther("100"));
        await staking.stake(ethers.utils.parseEther("100"), duration);
        const stakes = await staking.hasStake();
        expect(stakes.total_amount).to.equal(ethers.utils.parseEther("99"));

        await expect(staking.claimAirdrop()).to.be.revertedWith("Not Initialized");
    });
    it("Should claim airdrop successfully", async function () {
        const { token, staking } = await loadFixture(deployTokenFixture);
        const duration = 90 * 24 * 3600;

        await token.approve(staking.address, ethers.utils.parseEther("100"));
        await staking.stake(ethers.utils.parseEther("100"), duration);
        const stakes = await staking.hasStake();
        expect(stakes.total_amount).to.equal(ethers.utils.parseEther("99"));

        await staking.startAirdrop();
        await staking.claimAirdrop();
    });
});
