/**
 * @phase Secondary Market
 * NFT holder can sell their NFT in the Secondary market
 * Artist should get Royalties when NFT transaction being held
 */

const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

const nfts = [
    { URI: "abcde", price: "250" },
    { URI: "defg", price: "300" },
    { URI: "hijk", price: "150" },
];

const ROYALTY_PERCENTAGE = 100; // for 1%
const DURATION = hre.ethers.BigNumber.from("2592000"); // 30 days
const SOFT = hre.ethers.utils.parseEther("500");
const MEDIUM = hre.ethers.utils.parseEther("1000");
const HARD = hre.ethers.utils.parseEther("2000");

describe("Secondary_NFT_Test", function () {
    let signers;
    let token;
    let escrow;
    let nft;

    beforeEach(async function () {
        signers = await hre.ethers.getSigners();

        const Talaxeum = await hre.ethers.getContractFactory("Talaxeum");
        token = await Talaxeum.deploy();

        const ProjectNameEscrow = await hre.ethers.getContractFactory("ProjectNameEscrow");
        escrow = await ProjectNameEscrow.deploy(token.address);

        const ProjectNameNFT = await hre.ethers.getContractFactory("ProjectNameNFT");
        nft = await ProjectNameNFT.deploy();

        const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
        market = await NFTMarketplace.deploy(token.address);

        await escrow.init(token.address);
        await nft.init(token.address, escrow.address, ROYALTY_PERCENTAGE);

        await token.approve(escrow.address, hre.ethers.utils.parseEther("700"));
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[0].price), nfts[0].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[1].price), nfts[1].URI);
        await escrow.deposit(hre.ethers.utils.parseEther(nfts[2].price), nfts[2].URI);
        await time.increase(2592000);

        await escrow.mintNFT(nfts[0].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[0].price));
        await escrow.mintNFT(nfts[1].URI, signers[2].address, hre.ethers.utils.parseEther(nfts[1].price));
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
        console.log("NFT Marketplace address: ", market.address);

        const ownerBalance = await token.balanceOf(signers[0].address);
        const artistBalance = await token.balanceOf(signers[2].address);
        console.log("\nOwner Balance: ", ownerBalance);
        console.log("\nArtist Balance: ", artistBalance);
    });

    it("Should list successfully to the NFT marketplace contract", async function () {
        await nft.approve(market.address, 1);
        await market.listNft(nft.address, 1, hre.ethers.utils.parseEther("100.0"));
        console.log("\nShould list NFT successfully");
    });

    it("Should not buy NFT successfully to the NFT marketplace contract if the buyer is the seller", async function () {
        await nft.approve(market.address, 1);
        await market.listNft(nft.address, 1, hre.ethers.utils.parseEther("100.0")); // 100 Token
        console.log("\nShould list NFT successfully");

        const listing = await market.getListing(nft.address, 1);
        console.log("Listing: ", listing);

        await token.approve(market.address, hre.ethers.utils.parseEther("100.0"));
        await expect(market.buyNft(nft.address, 1)).to.be.revertedWith("Seller cannot buy owns NFT");
        console.log("\nSeller failed to buy owns NFT successfully");
    });

    it("Should buy NFT successfully to the NFT marketplace contract, the seller get the token successfully, and the artist get royalties successfully", async function () {
        await nft.approve(market.address, 1);
        await market.listNft(nft.address, 1, hre.ethers.utils.parseEther("100.0")); // 100 Token
        console.log("\nShould list NFT successfully");

        const listing = await market.getListing(nft.address, 1);
        const [artist, royalty] = await nft.royaltyInfo(1, hre.ethers.utils.parseEther("100.0"));
        console.log("Listing: ", listing);
        console.log("Artist: ", artist);
        console.log("Royalty: ", royalty);

        let owner = await nft.ownerOf(1);
        let sellerBalance = await token.balanceOf(signers[0].address);
        let buyerBalance = await token.balanceOf(signers[1].address);
        let artistBalance = await token.balanceOf(signers[2].address);
        console.log("Owner of NFT before selling through marketplace: ", owner);
        console.log("Seller Balance before selling: ", sellerBalance);
        console.log("Buyer Balance before selling: ", buyerBalance);
        console.log("Artist Balance before selling: ", artistBalance);

        await token.transfer(signers[1].address, hre.ethers.utils.parseEther("200.0"));
        await token.connect(signers[1]).approve(market.address, hre.ethers.utils.parseEther("100.0"));
        await market.connect(signers[1]).buyNft(nft.address, 1);

        owner = await nft.ownerOf(1);
        sellerBalance = await token.balanceOf(signers[0].address);
        buyerBalance = await token.balanceOf(signers[1].address);
        artistBalance = await token.balanceOf(signers[2].address);
        console.log("Owner of NFT after selling through marketplace: ", owner);
        console.log("Seller Balance after selling: ", sellerBalance);
        console.log("Buyer Balance after selling: ", buyerBalance);
        console.log("Artist Balance after selling: ", artistBalance);

        expect(owner).to.equal(signers[1].address);
        expect(buyerBalance).to.equal(await hre.ethers.utils.parseEther("98.0"));
        expect(artistBalance).to.equal(await hre.ethers.utils.parseEther("1.0"));

        console.log("\nSeller get token transferred successfully from buyer");
    });

    it("Should update listing successfully ", async function () {
        await nft.approve(market.address, 1);
        await market.listNft(nft.address, 1, hre.ethers.utils.parseEther("100.0")); // 100 Token

        await market.updateListing(nft.address, 1, hre.ethers.utils.parseEther("150.0")); // 150 Token
        const listing = await market.getListing(nft.address, 1);
        expect(listing.price).to.equal(hre.ethers.utils.parseEther("150.0"));
    });

    it("Should update listing failed successfully ", async function () {
        await nft.approve(market.address, 1);
        await market.listNft(nft.address, 1, hre.ethers.utils.parseEther("100.0")); // 100 Token

        await expect(
            market.connect(signers[1]).updateListing(nft.address, 1, hre.ethers.utils.parseEther("150.0"))
        ).to.be.revertedWith("Not Owner");
    });
});
