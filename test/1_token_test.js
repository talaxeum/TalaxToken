/**
 * @phase User stakes and withdraw
 * @phase Vesting Wallet (includes Team and Project Coordinator)
 * @phase User joins Whitelist
 */

const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");

const START_TIMESTAMP = BigNumber.from("");

/* ------------------------------------------- Vesting ------------------------------------------ */
const PUBLIC_SALE = {
    //! TGE 4 months duration 0 cliff
    address: "",
    duration: BigNumber.from(monthToSec(4)),
    cliff: BigNumber.from(monthToSec(0)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const TEAM_AND_PROJECT = {
    // 36 months duration 11 months cliffs
    duration: BigNumber.from(monthToSec(36)),
    cliff: BigNumber.from(monthToSec(11)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const MARKETING = {
    //! TGE 35 months duration 0 cliff
    address: "",
    duration: BigNumber.from(monthToSec(35)),
    cliff: BigNumber.from(monthToSec(0)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const STAKING_REWARD = {
    // 51 months duration 0 cliff
    address: "",
    duration: BigNumber.from(monthToSec(51)),
    cliff: BigNumber.from(monthToSec(0)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const LIQUIDITY_RESERVE = {
    // 51 months duration 0 cliff
    address: "",
    duration: BigNumber.from(monthToSec(51)),
    cliff: BigNumber.from(monthToSec(0)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const DAO_PROJECT_POOL = {
    // 51 months duration 0 cliff
    address: "",
    duration: BigNumber.from(monthToSec(51)),
    cliff: BigNumber.from(monthToSec(0)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
/* ------------------------------------------ Whitelist ----------------------------------------- */
const PRIVATE_SALE = {
    //! TGE 12 months duration 2 months cliffs
    duration: BigNumber.from(monthToSec(12)),
    cliff: BigNumber.from(monthToSec(2)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const SEED_SALE = {
    //! TGE 14 months duration 4 months cliffs
    duration: BigNumber.from(monthToSec(14)),
    cliff: BigNumber.from(monthToSec(4)),
    TGE: parseEther(""),
    amount: parseEther(""),
};
const STRATEGIC_PARTNER = {
    // 36 months duration 11 months cliffs
    duration: BigNumber.from(monthToSec(36)),
    cliff: BigNumber.from(monthToSec(11)),
    TGE: parseEther(""),
    amount: parseEther(""),
};

function monthToSec(num) {
    return String(num * 30 * 24 * 3600);
}

describe("Token_Test", function () {
    let token;
    let stake;
    let v_Factory;
    let w_factory;

    beforeEach(async function () {
        signers = await hre.ethers.getSigners();

        const Talaxeum = await hre.ethers.getContractFactory("Talaxeum");
        const Staking = await hre.ethers.getContractFactory("Staking");
        const VestingFactory = await hre.ethers.getContractFactory("VestingFactory");
        const WhitelistFactory = await hre.ethers.getContractFactory("WhitelistFactory");

        token = await Talaxeum.deploy();
        stake = await Staking.deploy(token.address);
        v_Factory = await VestingFactory.deploy();
        w_factory = await WhitelistFactory.deploy();
    });

    it("Should deploy all contract successfully", async function () {
        //Vesting
        //Whitelist
    });

    it("Should transfer token successfully and stake successfully", async function () {});
    it("Should withdraw stake successfully", async function () {});
    it("Should withdraw stake failed successfully", async function () {});

    it("Should deploy all contract successfully", async function () {});
    it("Should deploy all contract successfully", async function () {});
    it("Should deploy all contract successfully", async function () {});
    it("Should deploy all contract successfully", async function () {});
    it("Should deploy all contract successfully", async function () {});
    it("Should deploy all contract successfully", async function () {});
});
