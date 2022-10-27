/**
 * @phase Administrator propose a proposal for users to vote
 * @criteria Token Holder as voter
 * @criteria Staker as voter
 */

const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
