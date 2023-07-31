# NFTMarketplace Smart Contract Documentation

Table of Contents:

1. [Introduction](#introduction)
2. [Structs](#structs)
    - Listing
    - Bid
3. [Events](#events)
    - ItemListed
    - ItemCanceled
    - ItemBought
    - BidCreated
    - BidCancelled
    - BidAccepted
4. [Modifiers](#modifiers)
    - notListed
    - isListed
    - isNotListed
    - isBidAccepted
    - isOwner
    - isNotOwner
5. [Constructor](#constructor)
6. [Main Functions](#main-functions)
    - listItem
    - cancelListing
    - buyItem
    - updateListing
7. [Bidding Functions](#bidding-functions)
    - createBid
    - acceptBid
8. [Getter Functions](#getter-functions)
    - getListing

## Introduction

The `NFTMarketplace` smart contract is a marketplace contract that allows users to list their NFTs for sale and create bids on listed NFTs. Users can list their NFTs for a specified price and duration. Other users can make bids on the listed NFTs, and the owner of the NFT can accept the highest bid to complete the transaction.

## Structs

### `struct Listing`

This struct represents a listing for an NFT. It contains information such as the sale price, the seller's address, the end date of the listing, whether a bid has been accepted, and the details of the highest bid.

### `struct Bid`

This struct represents a bid made on a listed NFT. It contains information such as the bid price and the bidder's address.

## Events

### ItemListed

```solidity
event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price, uint256 endDate)
```

This event is emitted when an NFT is listed for sale on the marketplace.

### ItemCanceled

```solidity
event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId)
```

This event is emitted when a listing is canceled by the seller.

### ItemBought

```solidity
event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price)
```

This event is emitted when an NFT is successfully purchased from the marketplace.

### BidCreated

```solidity
event BidCreated(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 offeringPrice)
```

This event is emitted when a bid is created on a listed NFT.

### BidCanceled

```solidity
event BidCancelled(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId)
```

This event is emitted when a bid is canceled by the bidder.

### BidAccepted

```solidity
event BidAccepted(address seller, address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price)
```

This event is emitted when a bid is accepted by the owner of the NFT.

## Modifiers

### notListed

```solidity
modifier notListed(address nftAddress, uint256 tokenId)
```

This modifier checks if an NFT is not listed for sale.

### isListed

```solidity
modifier isListed(address nftAddress, uint256 tokenId)
```

This modifier checks if an NFT is listed for sale and has not expired.

### isNotListed

```solidity
modifier isNotListed(address nftAddress, uint256 tokenId)
```

This modifier checks if an NFT is not listed for sale.

### isBidAccepted

```solidity
modifier isBidAccepted(address nftAddress, uint256 tokenId)
```

This modifier checks if a bid has not been accepted for a listed NFT.

### isOwner

```solidity
modifier isOwner(address nftAddress, uint256 tokenId, address spender)
```

This modifier checks if the caller is the owner of the NFT.

### isNotOwner

```solidity
modifier isNotOwner(address nftAddress, uint256 tokenId, address spender)
```

This modifier checks if the caller is not the owner of the NFT.

## Constructor

```solidity
constructor(address _token)
```

The constructor initializes the `NFTMarketplace` contract with the specified token address.

## Main Functions

### listItem

```solidity
function listItem(address nftAddress, uint256 tokenId, uint256 price, uint256 duration) external
```

This function allows a user to list their NFT for sale on the marketplace.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id
-   `price`: The price of the NFT in eth
-   `duration`: The duration of the listing

### cancelListing

```solidity
function cancelListing(address nftAddress, uint256 tokenId) external
```

This function allows the owner of the NFT to cancel the listing.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id

### buyItem

```solidity
function buyItem(address nftAddress, uint256 tokenId) external payable
```

This function allows a user to purchase a listed NFT from the marketplace.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id

### updateListing

```solidity
function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice, uint256 additionalDuration) external
```

This function allows the owner of the NFT to update the listing price and duration.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id
-   `newPrice`: The new price to replace the old one
-   `additionalDuration`: The additional time to add

## Bidding Functions

### createBid

```solidity
function createBid(address nftAddress, uint256 tokenId, uint256 price) external payable
```

This function allows a user to create a bid on a listed NFT.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id
-   `price`: The price of the NFT in eth

### acceptBid

```solidity
function acceptBid(address nftAddress, uint256 tokenId) external
```

This function allows the owner of the NFT to accept the highest bid.

-   `nftAddress`: The NFT contract address
-   `tokenId`: The NFT token id

## Getter Functions

### getListing

```solidity
function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory)
```

This function allows users to retrieve information about a listing for a specific NFT.

-   `nftAddress`: The NFT contract address
-   `tokenID`: The NFT token id
