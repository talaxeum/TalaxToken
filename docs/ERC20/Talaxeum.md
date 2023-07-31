# Talaxeum ERC20 Contract Documentation

## Table of Contents

1. [Introduction](#introduction)
2. [Contract Overview](#contract-overview)
3. [Token Information](#token-information)
4. [Roles and Addresses](#roles-and-addresses)
5. [Functions](#functions)
    - [Constructor](#constructor)
    - [changeAdvisor](#changeadvisor)
    - [changePlatform](#changeplatform)
    - [getBalance](#getbalance)
    - [withdrawFunds](#withdrawfunds)
    - [withdrawTalax](#withdrawtalax)
    - [changeTax](#changetax)
    - [mint](#mint)
    - [transfer](#transfer)
    - [transferFrom](#transferfrom)
    - [approve](#approve)
    - [\_distributeTax](#_distributetax)
    - [\_transfer](#_transfer)
    - [fallback](#fallback)
    - [receive](#receive)
6. [Events](#events)
7. [Custom Error](#custom-error)

## Introduction

This is the documentation for the Talaxeum ERC20 smart contract. Talaxeum is an ERC20 token contract that extends from OpenZeppelin's ERC20, ERC20Burnable, and Ownable contracts. It includes features such as a tax on transfers and allows for minting of tokens by the contract owner.

## Contract Overview

-   **Contract Name:** Talaxeum
-   **Version:** 0.8.0
-   **License:** UNLICENSED
-   **Author:** Emveep
-   **SPDX-License-Identifier:** UNLICENSED

## Token Information

-   **Token Name:** Talaxeum
-   **Symbol:** TALAX
-   **Initial Supply:** 21 billion (21,000,000,000) tokens

## Roles and Addresses

-   **Advisor Address:** (initialized to address(0) but can be changed by the owner)
-   **Platform Address:** (initialized to address(0) but can be changed by the owner)
-   **Public Sale Address:** 0x5470c8FF25EC05980fc7C2967D076B8012298fE7
-   **Team and Project Coordinator Address:** 0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A
-   **Marketing Address:** 0xf09f65dD4D229E991901669Ad7c7549f060E30b9
-   **Staking Reward Address:** 0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A
-   **Liquidity Reserve Address:** 0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8
-   **DAO Pool Address:** 0x75837E79215250C45331b92c35B7Be506eD015AC

## Functions

### Constructor

The constructor initializes the token with the name "Talaxeum" and the symbol "TALAX". Additionally, it mints a total supply of 21 billion tokens to the contract deployer.

```solidity
constructor() ERC20("Talaxeum", "TALAX")
```

### changeAdvisor

```solidity
function changeAdvisor(address newAddress) external onlyOwner
```

This function is used to change the advisor address. Only the contract owner can call this function.

-   `newAddress`: The address of the new advisor.

### changePlatform

```solidity
function changePlatform(address newAddress) external onlyOwner
```

This function is used to change the platform address. Only the contract owner can call this function.

-   `newAddress`: The address of the new platform.

### getBalance

```solidity
function getBalance() public view returns (uint256)
```

This function allows querying the current balance of Ether held by the contract.

-   Returns: The balance of Ether in the contract.

### withdrawFunds

```solidity
function withdrawFunds() external onlyOwner
```

This function allows the contract owner to withdraw the entire Ether balance from the contract.

### withdrawTalax

```solidity
function withdrawTalax() external onlyOwner
```

This function allows the contract owner to withdraw the entire Talax token balance from the contract.

### changeTax

```solidity
function changeTax(uint256 tax) external onlyOwner
```

This function is used to change the tax rate applied to transfer transactions. Only the contract owner can call this function.

-   `tax`: The new tax amount in basis point format (0.01%).

### Mint

```solidity
function mint(address to, uint256 amount) public onlyOwner
```

This function is used by the contract owner to mint new Talax tokens and send them to the specified address.

-   `to`: The target address to receive the newly minted tokens.
-   `amount`: The amount of Talax tokens to mint and send.

### Transfer

```solidity
function transfer(address to, uint256 amount) public override returns (bool)
```

This function allows the caller to transfer Talax tokens to the target address while applying a tax fee.

-   `to`: The target address to receive the tokens.
-   `amount`: The amount of Talax tokens to transfer (excluding tax).

-   Returns: A boolean value indicating the success of the transfer.

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) public override returns (bool)
```

This function allows the caller (with approved allowance) to transfer Talax tokens from a specific source address to a target address while applying a tax fee.

-   `from`: The source address from which to transfer tokens.
-   `to`: The target address to receive the tokens.
-   `amount`: The amount of Talax tokens to transfer (excluding tax).

-   Returns: A boolean value indicating the success of the transfer.

### \_distributeTalax

```solidity
_distributeTax(address from, uint256 tax) internal
```

This function is called during token transfers to distribute the tax fee to the team_and_project_coordinator and this contract.

-   `from`: The address from which the tokens are transferred (sender).
-   `tax`: The amount of tax to be distributed.

### \_transfer

```solidity
_transfer(address from, address to, uint256 amount) internal override
```

This function is an internal override that handles the actual transfer of Talax tokens from one address to another. It is called by the `transfer` and `transferFrom` functions.

-   `from`: The source address from which to transfer tokens.
-   `to`: The target address to receive the tokens.
-   `amount`: The amount of Talax tokens to transfer.

### Events

```solidity
ChangeTaxPercentage(uint256 tax)
```

This event is emitted whenever the `changeTax` function is called to update the tax percentage for token transfers.

```solidity
ChangeAdvisorAddress(address indexed advisor)
```

This event is emitted when the `changeAdvisor` function is called to update the advisor's address.

```solidity
ChangePlatformAddress(address indexed platform)
```

This event is emitted when the `changePlatform` function is called to update the platform's address.

### Custom Error

```solidity
FailedToSendEther()
```

This error occurs when the contract owner attempts to withdraw Ether from the contract, but the transaction fails.

```solidity
ChangeAdvisorAddress(address indexed advisor)
```

This error occurs when attempting to change the tax rate, but the provided tax amount exceeds the maximum limit of 5% (500 basis points).
