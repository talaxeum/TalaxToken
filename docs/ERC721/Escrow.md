# ProjectEscrow Smart Contract Documentation

Table of Contents:

1. [Introduction](#introduction)
2. [Interfaces](#interfaces)
    - [`NFT`](#interface-nft)
    - [`Token`](#interface-token)
3. [Events](#events)
    - [`DurationChanged`](#durationchanged)
    - [`Deposit`](#deposit)
    - [`NftMinted`](#nftminted)
    - [`Withdraw`](#withdraw)
    - [`CapstoneReached`](#capstonereached)
    - [`FundClaimed`](#fundclaimed)
4. [Constructor](#constructor)
5. [Functions](#functions)
    - [`updateProjectRoot`](#updateprojectroot)
    - [`changeDuration`](#changeduration)
    - [`deposit`](#deposit-1)
    - [`mintNft`](#mintnft)
    - [`withdraw`](#withdraw-1)
    - [`claimFunding`](#claimfunding)
6. [Modifiers](#modifiers)
7. [Helpers](#helpers)
    - [`_isRunning`](#_isrunning)
    - [`_distribute`](#_distribute)
    - [`_count`](#_count)
    - [`_generateLeaf`](#_generateleaf)

## Introduction

The `ProjectEscrow` smart contract is a base escrow contract that holds funds designated for a payee until they withdraw them. It is intended to be a standalone contract, only interacting with the contract that instantiated it. The contract that uses the escrow as its payment method should be its owner and provide public methods redirecting to the escrow's deposit and withdraw.

## Interfaces

### `interface NFT`

This interface defines the functions required for an NFT (Non-Fungible Token) contract.

### `interface Token`

This interface defines the functions required for a token contract.

## Events

### DurationChanged

```solidity
event DurationChanged(address project, uint256 oldDeadline, uint256 newDealine)
```

This event is emitted when the duration of the project is changed.

### Deposit

```solidity
event Deposit(address indexed payee, uint256 projectId, address nftContract, string tokenUri, uint256 price)
```

This event is emitted when a deposit is made to the escrow.

### NftMinted

```solidity
event NftMinted(address indexed minter, uint256 projectId, address nftContract, string tokenUri)
```

This event is emitted when an NFT is minted.

### Withdraw

```solidity
event Withdraw(address indexed withdrawer, uint256 projectId, uint256 amount)
```

This event is emitted when a withdrawal is made from the escrow.

### CapstoneReached

```solidity
event CapstoneReached(address indexed project, uint256 status)
```

This event is emitted when the capstone for a project is reached.

### FundClaimed

```solidity
event FundClaimed(address indexed claimer, address project, uint256 amount)`
```

This event is emitted when the funding is claimed.

## Constructor

```solidity
constructor(address _token, uint256 _artistFee, uint256 _projectFee, uint256 _advisoryFee, uint256 _platformFee)
```

The constructor initializes the `ProjectEscrow` contract with the specified token address and fee percentages.

## Functions

### updateProjectRoot

```solidity
function updateProjectRoot(bytes32 _nftRoot, bytes32 _depositRoot) public onlyOwner
```

This function updates the project root with the provided NFT root and deposit root.

-   `_nftRoot`: The root of the nft merkle tree
-   `_depositRoot`: The root of the deposit merkle tree

### changeDuration

```solidity
function changeDuration(uint256 _additionalTime) external onlyOwner
```

This function allows the owner of the contract to change the duration of the project.

-   `_additionalTime`:The additional time for the escrow process

### Deposit

```solidity
function deposit(uint256 _projectId, address _nftContract, address _depositor, string memory _tokenUri, uint8 _status) public payable virtual onlyOwner
```

This function is used to make a deposit to the escrow for a specific project.

-   `_projectId`: The project id
-   `_nftContract`: The NFT Contract address
-   `_depositor`: The depositor address
-   `_tokenUri`: The token uri
-   `_status`: The status of the current escrow

### mintNft

```solidity
function mintNft(bytes32[] memory _proof, uint256 _projectId, address _nftContract, string memory _tokenUri) public payable isRunning
```

This function is used to mint an NFT after validating the Merkle proof.

-   `_proof`: The Merkle Proof
-   `_projectId`: The project id
-   `_nftContract`: The NFT contract address
-   `_tokenUri`: The token uri

### Withdraw

```solidity
function withdraw(bytes32[] memory _proof, uint256 _amount) public virtual isRunning
```

This function is used to withdraw funds from the escrow after validating the Merkle proof.

-   `_proof`: The Merkle Proof
-   `_amount`: The withdraw amount

### claimFunding

```solidity
function claimFunding() public onlyOwner isRunning
```

This function is used to claim the funding from the escrow.

## Modifiers

### isRunning

```solidity
modifier isRunning()
```

This modifier checks if the project is still running (not expired).

## Helpers

### \_isRunning

```solidity
_isRunning() internal view
```

This function checks if the project is still running (not expired).

### \_distribute

```solidity
_distribute(uint256 _artistFee, uint256 _advisoryFee, uint256 _platformFee, address _nftContract, uint256 _tokenPrice) internal
```

This function is used to distribute fees to the relevant addresses.

### \_count

```solidity
_count(uint256 amount, uint256 bps) internal pure returns (uint256)
```

This function calculates a value as a percentage of the total.

### \_generateLeaf

```solidity
_generateLeaf(bytes memory _encoded) internal pure returns (bytes32)
```

This function generates a Merkle leaf from encoded data.
