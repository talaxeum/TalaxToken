# NFT Smart Contract Documentation

Table of Contents:

1. [Introduction](#introduction)
2. [Constructor](#constructor)
3. [Royalties](#royalties)
4. [Functions](#functions)
    - [`supportsInterface`](#function-supportsinterfacebytes4-interfaceid-public-view-virtual-returns-bool)
    - [`safeMint`](#function-safemintaddress-to-string-memory-uri-public-onlyowner)
    - [`setTokenPrice`](#function-settokenpriceuint256-_tokenprice-public-onlyowner)
    - [`setRoyaltyPercentage`](#function-setroyaltypercentageuint96-_royaltypercentage-public-onlyowner)
    - [`tokenURI`](#function-tokenuriuint256-tokenid-public-view-override-returns-string-memory)
    - [`burn`](#function-burnuint256-tokenid-public)
    - [`royaltyInfo`](#function-royaltyinfouint256-tokenid-uint256-saleprice-public-view-override-returns-address-receiver-uint256-royaltyamount)
5. [Overrides](#overrides)
6. [Inherited Contracts](#inherited-contracts)
7. [Example](#example)

## Introduction

The NFT (Non-Fungible Token) smart contract is an ERC721-compliant contract that allows the creation and management of non-fungible tokens with URI storage capabilities. It also implements the ERC2981 standard for royalties, allowing the creator to receive royalties on secondary sales.

## Constructor

```solidity
constructor(address _artist, uint96 _royaltyPercentage, uint256 _tokenPrice)
```

The constructor initializes the NFT contract with the following parameters:

-   `_artist`: The address of the artist or creator of the NFT, who will receive royalties.
-   `_royaltyPercentage`: The royalty percentage that the artist will receive on secondary sales.
-   `_tokenPrice`: The price of the NFT in wei.

## Royalties

The `NFT` contract implements the ERC2981 standard for royalties, which allows the creator to receive royalties on secondary sales. The royalty percentage is set during contract deployment and can be modified by the owner.

## Functions

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

This function checks if the contract supports a given interface.

-   `interfaceId`: The interface id

### safeMint

```solidity
function safeMint(address to, string memory uri) public onlyOwner
```

This function is used to safely mint a new NFT and assign it to the specified address.

-   `to`: The target address to receive newly minted NFT
-   `uri`: The uri of the NFT

### setTokenPrice

```solidity
function setTokenPrice(uint256 _tokenPrice) public onlyOwner
```

This function allows the owner of the contract to set the price of the NFT in wei.

-   `_tokenPrice`: The new token price

### setRoyaltyPercentage

```solidity
function setRoyaltyPercentage(uint96 _royaltyPercentage) public onlyOwner
```

This function allows the owner of the contract to set the royalty percentage that the artist will receive on secondary sales.

-   `_royaltyPercentage`: The new royalty percentage

### tokenUri

```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory)
```

This function returns the URI for the metadata of the specified NFT.

-   `tokenId`: The NFT token id

### Burn

```solidity
function burn(uint256 tokenId) public
```

This function allows the owner of the NFT to burn (destroy) the specified NFT.

-   `tokenId`: The NFT token id

### royaltyInfo

```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice) public view override returns (address receiver, uint256 royaltyAmount)
```

This function is required by the ERC2981 standard and returns the royalty information for a given NFT.

-   `tokenId`: The NFT token id
-   `salePrice`: The sale price of the token

## Overrides

The `NFT` contract provides overrides for the following functions:

```solidity
_burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
```

This internal function is called when an NFT is burned (destroyed).

## Inherited Contracts

The `NFT` contract inherits from the following OpenZeppelin contracts:

-   `ERC721`: This contract provides the implementation of the ERC721 standard for non-fungible tokens.
-   `ERC721URIStorage`: This contract adds support for token URIs, allowing metadata to be associated with each token.
-   `ERC721Burnable`: This contract adds support for burning (destroying) NFTs.
-   `Ownable`: This contract provides basic access control functionality, allowing only the owner to perform certain actions.

## Example

To use the `NFT` contract, deploy it with the appropriate constructor parameters. The owner of the contract can then mint new NFTs using the `safeMint` function, set the token price and royalty percentage, and burn NFTs if needed. The royalties will be automatically calculated and distributed to the artist on secondary sales according to the specified percentage.
