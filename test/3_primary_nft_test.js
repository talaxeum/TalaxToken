/**
 * @phase Primary Market
 * Artists create picture, Talax provide the metadata and setup the IPFS
 * Project will be chosen with governance voting, voters are token holders
 * Token holders then can support the project that they want with buying a NFT and transfer it first to the Escrow Contract // Step 1
 * After the duration of the Crowdfunding finished, if the capstone is fulfilled, the token will be transferred to the NFT contract and NFT can be minted by the user
 * The Project Owner can withdraw the token transferred into the NFT contract
 * The Project Owner can transfer reward that can be claimed by NFT holder
 */

const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

const nfts = [
    { URI: "abcde", price: "250" },
    { URI: "defg", price: "300" },
    { URI: "hijk", price: "150" },
];

const ROYALTY_PERCENTAGE = 1; // for 1%
const DURATION = hre.ethers.BigNumber.from("2592000"); // 30 days
const SOFT = hre.ethers.utils.parseEther("500");
const MEDIUM = hre.ethers.utils.parseEther("1000");
const HARD = hre.ethers.utils.parseEther("2000");

describe("Primary_NFT_Test", function () {
    let signers;
    let token;
    let escrow;
    let nft;

    beforeEach(async function () {
        signers = await hre.ethers.getSigners();

        const Talaxeum = await hre.ethers.getContractFactory("Talaxeum");
        token = await Talaxeum.deploy();

        const ProjectNameEscrow = await hre.ethers.getContractFactory("ProjectNameEscrow");
        escrow = await ProjectNameEscrow.deploy();

        const ProjectNameNFT = await hre.ethers.getContractFactory("ProjectNameNFT");
        nft = await ProjectNameNFT.deploy();

        await escrow.init(token.address, nft.address, DURATION, SOFT, MEDIUM, HARD);
        await nft.init(token.address, escrow.address, ROYALTY_PERCENTAGE);
    });

    it("Should deploy", async function () {
        console.log("Signers");
        console.log("==========================================");
        signers.forEach((signer) => {
            console.log(signer.address);
        });
        console.log("==========================================");

        console.log("Token address: ", token.address);
        console.log("Escrow address: ", escrow.address);
        console.log("NFT address: ", nft.address);

        const ownerBalance = await token.balanceOf(signers[0].address);
        console.log("\nOwner Balance: ", ownerBalance);
    });

    it("Should transferred correctly to the Escrow Contract", async function () {
        await token.transfer(escrow.address, hre.ethers.utils.parseEther("10.0"));
        const escrowBalance = await token.balanceOf(escrow.address);
        console.log("\nEscrow Balance after Transfer: ", escrowBalance);
        expect(escrowBalance).to.equal(await hre.ethers.utils.parseEther("9.9"));
    });

    it("Should failed the crowdfund process", async function () {
        await time.increase(2592000);
        const escrowStatus = await escrow.getStatus();
        console.log("\nEscrow Status: ", escrowStatus);
        expect(escrowStatus).to.equal(0);
        await expect(
            escrow.mintNFT(nfts[0].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[0].price))
        ).to.be.revertedWith("This NFT is not Allowed");
        console.log("\nEscrow mintNFT failed successfully with expected Revert Message");
    });

    it("Should complete crowdfund and minting process", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        const escrowStatus = await escrow.getStatus();
        expect(escrowStatus).to.equal(1);
        await time.increase(2592000);

        await escrow.mintNFT(nfts[0].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[0].price));
        await escrow.mintNFT(nfts[1].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[1].price));
        console.log("\nShould mint NFT Successfully");
    });

    it("Should complete the crowdfund and failed the minting process", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        const escrowStatus = await escrow.getStatus();
        expect(escrowStatus).to.equal(1);
        await time.increase(2592000);

        await expect(
            escrow.mintNFT(nfts[2].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[2].price))
        ).to.be.revertedWith("This NFT is not Allowed");
        console.log("\nEscrow mintNFT failed successfully with expected Revert Message");
    });

    it("Should complete the crowdfund and failed the minting process when called directly from NFT contract", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        const escrowStatus = await escrow.getStatus();
        expect(escrowStatus).to.equal(1);
        await time.increase(2592000);

        await expect(
            nft.mintNFTWithRoyalty(
                signers[0].address,
                nfts[0].URI,
                signers[2].address,
                hre.ethers.utils.parseEther(nfts[0].price)
            )
        ).to.be.revertedWith("Not Authorized");
        console.log("\nmintNFTWithRoyalty failed successfully with expected Revert Message");
    });

    it("Should transfer token successfully from the Escrow contract", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        await time.increase(2592000);

        await escrow.transferEscrowBalance(nft.address);
        const nftBalance = await token.balanceOf(nft.address);
        console.log("\nNFT Balance after Transfer: ", nftBalance);
        expect(nftBalance).to.equal(await hre.ethers.utils.parseEther("693.0"));
    });

    it("Should transfer token failed from the Escrow contract by not project owner", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        await time.increase(2592000);

        await expect(escrow.connect(signers[2]).transferEscrowBalance(nft.address)).to.be.revertedWith(
            "Ownable: caller is not the owner"
        );
        console.log("\nTransfer token failed successfully from Escrow contract");
    });

    it("Should transfer successfully by project owner and claim correctly by NFT holder", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        const escrowStatus = await escrow.getStatus();
        expect(escrowStatus).to.equal(1);
        await time.increase(2592000);

        await escrow.mintNFT(nfts[0].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[0].price));
        await escrow.mintNFT(nfts[1].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[1].price));
        console.log("\nShould mint NFT Successfully");

        await nft.claimReward(1);
        await nft.claimReward(2);
        console.log("\nShould claim reward Successfully");
    });
    it("Should transfer successfully by project owner and failed to claimed by non NFT holder", async function () {
        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        const escrowStatus = await escrow.getStatus();
        expect(escrowStatus).to.equal(1);
        await time.increase(2592000);

        await escrow.mintNFT(nfts[0].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[0].price));
        await escrow.mintNFT(nfts[1].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[1].price));
        console.log("\nShould mint NFT Successfully");

        await expect(nft.connect(signers[2]).claimReward(1)).to.be.revertedWith("Not eligible to claim reward");
        console.log("\nClaim reward failed successfully from NFT contract");
    });
});
