const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Token contract", function () {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Talaxeum");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const token = await Token.deploy();

        await token.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, token, owner, addr1, addr2 };
    }

    it("Should assign the total supply of tokens to the owner", async function () {
        const { token, owner } = await loadFixture(deployTokenFixture);
        const ownerBalance = await token.balanceOf(owner.address);
        expect(await token.totalSupply()).to.equal(ownerBalance);
    });

    it("Should transfer tokens between accounts (including tax)", async function () {
        const { token, owner, addr1 } = await loadFixture(deployTokenFixture);

        // Transfer 50 tokens from owner to addr1
        await expect(token.transfer(addr1.address, 500)).to.changeTokenBalances(token, [owner, addr1], [-500, 495]);

        const ownerBalance = await token.balanceOf(owner.address);
        const toBalance = await token.balanceOf(addr1.address);
        console.log(ownerBalance);
        console.log(toBalance);
    });

    it("Should change tax rate", async function () {
        const { token } = await loadFixture(deployTokenFixture);

        // Change the tax rate into 2
        await token.changeTax(2);
        await expect(await token.taxRate()).to.equal(2);
    });

    it("Should not change tax rate if not owner called", async function () {
        const { token, addr1 } = await loadFixture(deployTokenFixture);

        // Change the tax rate into 2
        await expect(token.connect(addr1).changeTax(2)).to.be.revertedWith("Ownable: caller is not the owner");
    });
});
