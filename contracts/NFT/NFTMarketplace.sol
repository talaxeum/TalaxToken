// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./ProjectNameNFT.sol";

// Check out https://github.com/Fantom-foundation/Artion-Contracts/blob/5c90d2bc0401af6fb5abf35b860b762b31dfee02/contracts/FantomMarketplace.sol
// For a full decentralized nft marketplace

// error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
// error NftNotForSale(address nftAddress, uint256 tokenId);
// error NotListed(address nftAddress, uint256 tokenId);
// error AlreadyListed(address nftAddress, uint256 tokenId);
// error NoProceeds();
// error NotOwner();
// error IsNotOwner();
// error NotApprovedForMarketplace();
// error PriceMustBeAboveZero();

// Error thrown for isNotOwner modifier
// error IsNotOwner()

contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        uint256 price;
        address seller;
    }

    event NftListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event NftCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event NftBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    // mapping(address => uint256) private s_proceeds; //mapping for what sellers earn from their selling
    address public token;

    constructor(address _token) {
        token = _token;
    }

    modifier notListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        // if (listing.price > 0) {
        //     revert AlreadyListed(nftAddress, tokenId);
        // }
        require(listing.price <= 0, "Already Listed");
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        // if (listing.price <= 0) {
        //     revert NotListed(nftAddress, tokenId);
        // }
        require(listing.price > 0, "Not Listed");
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        // if (spender != owner) {
        //     revert NotOwner();
        // }
        require(spender == owner, "Not Owner");
        _;
    }

    // IsNotOwner Modifier - Nft Owner can't buy his/her NFT
    // Modifies buyNft function
    // Owner should only list, cancel listing or update listing
    modifier isNotOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        // if (spender == owner) {
        //     revert IsNotOwner();
        // }
        require(spender != owner, "Seller cannot buy owns NFT");
        _;
    }

    /////////////////////
    // Main Functions //
    /////////////////////
    /**
     * @notice Method for listing NFT
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param price sale price for each item
     */
    function listNft(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        // if (price <= 0) {
        //     revert PriceMustBeAboveZero();
        // }
        require(price > 0, "Price must be above zero");
        IERC721 nft = IERC721(nftAddress);
        // if (nft.getApproved(tokenId) != address(this)) {
        //     revert NotApprovedForMarketplace();
        // }
        require(
            nft.getApproved(tokenId) == address(this),
            "Not Approved for Marketplace"
        );
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit NftListed(msg.sender, nftAddress, tokenId, price);
    }

    /**
     * @notice Method for cancelling listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit NftCanceled(msg.sender, nftAddress, tokenId);
    }

    /**
     * @notice Method for buying listing
     * @notice The owner of an NFT could unapprove the marketplace,
     * which would cause this function to fail
     * Ideally you'd also have a `createOffer` functionality.
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function buyNft(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        // Challenge - How would you refactor this contract to take:
        // 1. Abitrary tokens as payment? (HINT - Chainlink Price Feeds!)
        // 2. Be able to set prices in other currencies?
        // 3. Tweet me @PatrickAlphaC if you come up with a solution!
        Listing memory listedNft = s_listings[nftAddress][tokenId];
        (address artist, uint256 royalty) = ProjectNameNFT(nftAddress)
            .royaltyInfo(tokenId, listedNft.price);

        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, artist, royalty);
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            listedNft.seller,
            listedNft.price - royalty
        );
        // s_proceeds[listedNft.seller] += listedNft.price;
        // Could just send the money...
        // https://fravoll.github.io/solidity-patterns/pull_over_push.html
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(
            listedNft.seller,
            msg.sender,
            tokenId
        );
        emit NftBought(msg.sender, nftAddress, tokenId, listedNft.price);
    }

    /**
     * @notice Method for updating listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param newPrice Price in Wei of the item
     */
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftAddress, tokenId)
        nonReentrant
        isOwner(nftAddress, tokenId, msg.sender)
    {
        //We should check the value of `newPrice` and revert if it's below zero (like we also check in `listNft()`)
        // if (newPrice <= 0) {
        //     revert PriceMustBeAboveZero();
        // }
        require(newPrice > 0, "Price must be above zero");
        s_listings[nftAddress][tokenId].price = newPrice;
        emit NftListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    // /**
    //  * @notice Method for withdrawing proceeds from sales
    //  */
    // function withdrawProceeds() external {
    //     uint256 proceeds = s_proceeds[msg.sender];
    //     if (proceeds <= 0) {
    //         revert NoProceeds();
    //     }
    //     s_proceeds[msg.sender] = 0;
    //     (bool success, ) = payable(msg.sender).call{value: proceeds}("");
    //     require(success, "Transfer failed");
    // }

    /////////////////////
    // Getter Functions //
    /////////////////////

    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return s_listings[nftAddress][tokenId];
    }

    // function getProceeds(address seller) external view returns (uint256) {
    //     return s_proceeds[seller];
    // }
}
