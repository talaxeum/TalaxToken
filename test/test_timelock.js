const {
    loadFixture,
    time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const tokenAbi = require("../artifacts/contracts/ERC20/Talaxeum.sol/Talaxeum.json");
const iface = new ethers.utils.Interface(tokenAbi.abi);

describe("Timelock mechanism", () => {
    async function deployTokenFixture() {
        const Token = await ethers.getContractFactory("Talaxeum");
        const [owner, addr1, addr2] = await ethers.getSigners();

        const token = await Token.deploy();
        await token.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, token, owner, addr1, addr2 };
    }

    async function deployTimeLockFixture() {
        const TimeLock = await ethers.getContractFactory("TimeLock");
        const [owner] = await ethers.getSigners();

        const timeLock = await TimeLock.deploy();
        await timeLock.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { TimeLock, timeLock };
    }

    it("Schedule and Execute", async () => {
        const { token } = await loadFixture(deployTokenFixture);
        const { timeLock } = await loadFixture(deployTimeLockFixture);

        const target = token.address;
        const value = 0;
        const calldata = iface.encodeFunctionData("changeAdvisor", [
            timeLock.address,
        ]);

        // Transfer the ownership to Timelock.sol
        await token.transferOwnership(timeLock.address);

        // Queue an onlyOwner function
        const tx = await timeLock.queue(target, value, calldata);
        const receipt = await tx.wait();

        // Get timestamp from event
        let timestamp;
        for (x of receipt.events) {
            if (x.event == "Queue") timestamp = x.args.timestamp;
        }
        console.log("TIMESTAMP", timestamp);

        // Increase the time to after the delay
        await time.increase(48 * 3600);

        // Check the before
        let advisor = await token.advisor();
        console.log("BEFORE", advisor);

        // Call the execute function from Timelock.sol
        await timeLock.execute(target, value, calldata, timestamp);

        // Check the after
        advisor = await token.advisor();
        console.log("AFTER", advisor);
    });
});
