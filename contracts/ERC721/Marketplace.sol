// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// modified version of marketplace contract from this https://github.com/smartcontractkit/full-blockchain-solidity-course-js

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error Listed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error BidAlreadyAccepted(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error IsNotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error PriceMustBeGreater();
error NotBidder();

// Error thrown for isNotOwner modifier
// error IsNotOwner()
// TODO: Implement Royalties for NFT Transactions (Using Talax or Ethers)

contract NFTMarketplace is ReentrancyGuard {
    // Bid and Make Offer Differ in Status
    // Bid => Auction Status
    // Make Offer => Not on Sale Status
    struct Listing {
        uint256 price;
        address seller;
        uint256 endDate;
        bool bidAccepted;
        Bid s_bid;
    }
    struct Bid {
        uint256 price;
        address buyer;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        uint256 endDate
    );
    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event BidCreated(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 offeringPrice
    );
    event BidCancelled(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    event BidAccepted(
        address seller,
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    address private token;

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    // mapping(address => uint256) private s_proceeds;

    modifier notListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        if (listing.endDate > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        if (listing.endDate < block.timestamp) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price >= 0) {
            revert Listed(nftAddress, tokenId);
        }
        if (listing.endDate > block.timestamp) {
            revert Listed(nftAddress, tokenId);
        }
        _;
    }

    modifier isBidAccepted(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.bidAccepted) {
            revert BidAlreadyAccepted(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    // IsNotOwner Modifier - Nft Owner can't buy his/her NFT
    // Modifies buyItem function
    // Owner should only list, cancel listing or update listing
    modifier isNotOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender == owner) {
            revert IsNotOwner();
        }
        _;
    }

    /////////////////////
    //   Constructor   //
    /////////////////////

    constructor(address _token) {
        token = _token;
    }

    /////////////////////
    // Main Functions //
    /////////////////////
    /**
     * @notice Method for listing NFT
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param price sale price for each item
     * @param duration listing duration for each item
     */
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 duration
    )
        external
        notListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (price == 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = Listing(
            price,
            msg.sender,
            block.timestamp + duration,
            false,
            Bid(0, address(0))
        );
        emit ItemListed(
            msg.sender,
            nftAddress,
            tokenId,
            price,
            block.timestamp + duration
        );
    }

    /**
     * @notice Method for cancelling listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function cancelListing(
        address nftAddress,
        uint256 tokenId
    )
        external
        isOwner(nftAddress, tokenId, msg.sender)
        isListed(nftAddress, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    /**
     * @notice Method for buying listing
     * @notice The owner of an NFT could unapprove the marketplace,
     * which would cause this function to fail
     * Ideally you'd also have a `createOffer` functionality.
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function buyItem(
        address nftAddress,
        uint256 tokenId
    )
        external
        payable
        isListed(nftAddress, tokenId)
        isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        // Challenge - How would you refactor this contract to take:
        // 1. Abitrary tokens as payment? (HINT - Chainlink Price Feeds!)
        // 2. Be able to set prices in other currencies?
        // 3. Tweet me @PatrickAlphaC if you come up with a solution!
        Listing memory listedItem = s_listings[nftAddress][tokenId];

        // Could just send the money...
        // https://fravoll.github.io/solidity-patterns/pull_over_push.html
        delete (s_listings[nftAddress][tokenId]);
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            listedItem.seller,
            listedItem.price
        );
        IERC721(nftAddress).safeTransferFrom(
            listedItem.seller,
            msg.sender,
            tokenId
        );
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
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
        uint256 newPrice,
        uint256 additionalDuration
    )
        external
        isListed(nftAddress, tokenId)
        nonReentrant
        isOwner(nftAddress, tokenId, msg.sender)
    {
        //We should check the value of `newPrice` and revert if it's below zero (like we also check in `listItem()`)
        if (newPrice == 0) {
            revert PriceMustBeAboveZero();
        }
        s_listings[nftAddress][tokenId].price = newPrice;

        uint256 newEndDate = s_listings[nftAddress][tokenId].endDate +
            additionalDuration;

        s_listings[nftAddress][tokenId].endDate = newEndDate;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice, newEndDate);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                        Bidding Functions                                       */
    /* ---------------------------------------------------------------------------------------------- */

    /**
     * @notice Method for create Bidding (Bid on a listed NFT)
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param price Amount of placed bid
     */
    function createBid(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        payable
        isBidAccepted(nftAddress, tokenId)
        isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (price < listedItem.s_bid.price) {
            revert PriceMustBeGreater();
        }
        listedItem.s_bid = Bid(price, msg.sender);

        emit BidCreated(msg.sender, nftAddress, tokenId, price);
    }

    /**
     * @notice Method to accept Bid (Only callable by owner of NFT)
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     */
    function acceptBid(
        address nftAddress,
        uint256 tokenId
    ) external nonReentrant isOwner(nftAddress, tokenId, msg.sender) {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        Bid memory bid = listedItem.s_bid;

        listedItem.bidAccepted = true;

        delete (s_listings[nftAddress][tokenId]);
        SafeERC20.safeTransferFrom(
            IERC20(token),
            bid.buyer,
            msg.sender,
            bid.price
        );
        IERC721(nftAddress).safeTransferFrom(
            listedItem.seller,
            msg.sender,
            tokenId
        );
        emit BidAccepted(
            listedItem.seller,
            msg.sender,
            nftAddress,
            tokenId,
            listedItem.price
        );
    }

    /**
     * @notice Method for withdrawing proceeds from sales
     */
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

    function getListing(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }

    // function getProceeds(address seller) external view returns (uint256) {
    //     return s_proceeds[seller];
    // }
}
