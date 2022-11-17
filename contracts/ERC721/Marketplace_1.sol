// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _nftsSold;
    Counters.Counter private _nftCount;
    uint256 public LISTING_FEE = 0.0001 ether;
    address payable private _marketOwner;
    mapping(uint256 => NFT) private _idToNFT;
    mapping(address => mapping(uint256 => mapping(address => Bid))) _offerings;
    struct NFT {
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool listed;
        bool secondhandNFT;
    }
    struct Bid {
        uint256 price;
        address buyer;
    }
    event BidPlaced(
        address nftContract,
        uint256 tokenId,
        address bidder,
        uint256 price
    );
    event BidCancelled(address nftContract, uint256 tokenId, address bidder);
    event BidAccepted(
        address nftContract,
        uint256 tokenId,
        address seller,
        address newOwner,
        uint256 price
    );
    event NFTListed(
        address nftContract,
        uint256 tokenId,
        address seller,
        address owner,
        uint256 price
    );
    event NFTSold(
        address nftContract,
        uint256 tokenId,
        address seller,
        address newOwner,
        uint256 price
    );

    constructor() {
        _marketOwner = payable(msg.sender);
    }

    // List the NFT on the marketplace
    function listNft(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        _nftCount.increment();

        _idToNFT[_nftCount.current()] = NFT(
            _nftContract,
            _tokenId,
            payable(msg.sender),
            payable(address(this)),
            _price,
            true,
            false
        );

        emit NFTListed(
            _nftContract,
            _tokenId,
            msg.sender,
            address(this),
            _price
        );
    }

    // Buy an NFT
    function buyNft(address _nftContract, uint256 _id)
        public
        payable
        nonReentrant
    {
        NFT storage nft = _idToNFT[_id];
        require(
            msg.value >= nft.price,
            "Not enough ether to cover asking price"
        );

        address payable buyer = payable(msg.sender);
        payable(nft.seller).transfer(msg.value);
        IERC721(_nftContract).transferFrom(address(this), buyer, nft.tokenId);
        _marketOwner.transfer(LISTING_FEE);
        nft.owner = buyer;
        nft.listed = false;
        nft.secondhandNFT = true;

        _nftsSold.increment();
        emit NFTSold(_nftContract, nft.tokenId, nft.seller, buyer, msg.value);
    }

    // Place bid for NFT
    // Need to approve token in the front end
    function placeBid(
        address _nftContract,
        uint256 _id,
        uint256 _price
    ) public nonReentrant {
        // require(
        //     allowance(msg.sender, address(this)) >= _price,
        //     "Not enough allowance"
        // );
        NFT memory nft = _idToNFT[_id];
        _offerings[_nftContract][nft.tokenId][msg.sender] = Bid(
            _price,
            msg.sender
        );
        emit BidPlaced(_nftContract, nft.tokenId, msg.sender, _price);
    }

    function cancelBid(address _nftContract, uint256 _id) public nonReentrant {
        NFT memory nft = _idToNFT[_id];
        delete (_offerings[_nftContract][nft.tokenId][msg.sender]);
        emit BidCancelled(_nftContract, nft.tokenId, msg.sender);
    }

    // Need validation if msg.sender is NFT owner
    // nft.secondhandNFT changed to true in this function
    function acceptBid(
        address _nftContract,
        uint256 _id,
        address bidder
    ) public nonReentrant {
        NFT storage nft = _idToNFT[_id];
        address payable buyer = payable(bidder);
        uint256 price = _offerings[_nftContract][nft.tokenId][bidder].price;
        // Transfer token
        // Transfer NFT
        nft.owner = buyer;
        nft.listed = false;
        nft.secondhandNFT = true;

        _nftsSold.increment();
        emit BidAccepted(_nftContract, nft.tokenId, nft.seller, buyer, price);
    }

    // Resell an NFT purchased from the marketplace
    // If nft.secondhandNFT == true, use this function to sell NFT
    function resellNft(
        address _nftContract,
        uint256 _id,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Price must be at least 1 wei");
        require(msg.value == LISTING_FEE, "Not enough ether for listing fee");

        NFT storage nft = _idToNFT[_id];
        IERC721(_nftContract).transferFrom(
            msg.sender,
            address(this),
            nft.tokenId
        );

        nft.seller = payable(msg.sender);
        nft.owner = payable(address(this));
        nft.listed = true;
        nft.price = _price;

        _nftsSold.decrement();
        emit NFTListed(
            _nftContract,
            nft.tokenId,
            msg.sender,
            address(this),
            _price
        );
    }

    function getListingFee() public view returns (uint256) {
        return LISTING_FEE;
    }

    function getListedNfts() public view returns (NFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 unsoldNftsCount = nftCount - _nftsSold.current();

        NFT[] memory nfts = new NFT[](unsoldNftsCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].listed) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }

    function getMyNfts() public view returns (NFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 myNftCount = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                myNftCount++;
            }
        }

        NFT[] memory nfts = new NFT[](myNftCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }

    function getMyListedNfts() public view returns (NFT[] memory) {
        uint256 nftCount = _nftCount.current();
        uint256 myListedNftCount = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (
                _idToNFT[i + 1].seller == msg.sender && _idToNFT[i + 1].listed
            ) {
                myListedNftCount++;
            }
        }

        NFT[] memory nfts = new NFT[](myListedNftCount);
        uint256 nftsIndex = 0;
        for (uint256 i = 0; i < nftCount; i++) {
            if (
                _idToNFT[i + 1].seller == msg.sender && _idToNFT[i + 1].listed
            ) {
                nfts[nftsIndex] = _idToNFT[i + 1];
                nftsIndex++;
            }
        }
        return nfts;
    }
}
