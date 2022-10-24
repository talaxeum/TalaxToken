/**
 * @phase Primary Market
 * Artists create picture, Talax provide the metadata and setup the IPFS
 * Project will be chosen with governance voting, voters are token holders
 * Token holders then can support the project that they want with buying a NFT and transfer it first to the Escrow Contract // Step 1
 * After the duration of the Crowdfunding finished, if the capstone is fulfilled, the token will be transferred to the NFT contract and NFT can be minted by the user
 * The Project Owner can withdraw the token transferred into the NFT contract
 * The Project Owner can transfer reward that can be claimed by NFT holder
 */

/**
 * @phase Secondary Market
 * NFT holder can sell their NFT in the Secondary market
 * Artist should get Royalties when NFT transaction being held
 */

const hardhat = require("hardhat");
const { ethers } = hardhat;
const { expect } = require("chai");

const TOKEN_ADDRESS = "";
const ESCROW_ADDRESS = "";

describe("NFT_test", function () {
    it("Should deploy", async function () {
        const signers = await ethers.getSigners();
        // signers.forEach((signer) => {
        //     console.log(signer.address);
        // });
        const minter = signers[0].address;

        const ProjectNameEscrow = await ethers.getContractFactory("ProjectNameEscrow");
        const escrow = await ProjectNameEscrow.deploy();
        await escrow.deployed();
        // await escrow.init(TOKEN_ADDRESS);

        const ProjectNameNFT = await ethers.getContractFactory("ProjectNameNFT");
        const nft = await ProjectNameNFT.deploy();
        await nft.deployed();
        // await nft.init(TOKEN_ADDRESS, ESCROW_ADDRESS);
    });

    it("Should transferred correctly to the Escrow Contract", async function () {});
    it("Should failed the crowdfund process", async function () {});
    it("Should complete the minting process", async function () {});
    it("Should withdraw token successfully from the NFT contract", async function () {});
    it("Should withdraw token failed from the NFT contract by not project owner", async function () {});
    it("Should transfer successfully by project owner and claim correctly by NFT holder", async function () {});
    it("Should transfer successfully by project owner and failed to claimed by non NFT holder", async function () {});
});
