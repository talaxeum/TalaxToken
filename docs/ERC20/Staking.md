# Staking Smart Contract Documentation

Table of Contents

1. [Constructor](#constructor)
2. [Events](#events)
3. [Functions](#functions)
    - [changePenaltyFee](#changepenaltyfee)
    - [stake](#stake)
    - [withdrawStake](#withdrawstake)
    - [startAirdrop](#startairdrop)
    - [changeAirdropPercentage](#changeairdroppercentage)
    - [claimAirdrop](#claimairdrop)
    - [getStake](#getstake)
    - [hasStake](#hasstake)
4. [Custom Errors](#custom-errors)
    - [FailedToSendEther()](#failedtosendether)
    - [TaxLimitError(bytes32 tax)](#taxlimiterror)

The Staking smart contract allows users to stake tokens for a specified period and earn rewards. It supports penalty fees for early withdrawal and airdrop rewards. Below is the detailed documentation for each function, event, and custom error within the contract.

## Constructor

The constructor initializes the Staking contract.

-   `token`: The address of the ERC20 token used for staking.

## Events

```solidity
Staked(address indexed user, uint256 amount, uint256 timestamp, uint256 releaseTime)
```

This event is triggered whenever a user stakes tokens.

```solidity
StakeClaimed(address indexed user, uint256 claimed, uint256 timestamp)
```

This event is triggered whenever a user claims their staking rewards or withdraws their stake.

```solidity
PenaltyChanged(uint256 amount)
```

This event is triggered when the penalty fee for early withdrawal is changed.

```solidity
AirdropChanged(uint256 amount)
```

This event is triggered when the airdrop percentage is changed.

## Functions

### changePenaltyFee

```solidity
function changePenaltyFee(uint256 amount) external onlyOwner
```

This function allows the contract owner to change the penalty fee for early withdrawal.

-   `amount`: The new penalty fee percentage in basis point format (0.01%).

### Stake

```solidity
function stake(uint256 amount, uint256 stakePeriod) external nonReentrant
```

This function allows a user to stake tokens for a specified period.

-   `amount`: The amount of tokens to stake.
-   `stakePeriod`: The duration of the stake in days (90, 180, or 365).

### withdrawStake

```solidity
function withdrawStake() external nonReentrant
```

This function allows a user to withdraw their staked tokens along with the staking rewards. It takes into account the penalty fee for early withdrawal if applicable.

### startAirdrop

```solidity
function startAirdrop() external onlyOwner
```

This function allows the contract owner to start the airdrop rewards. Users can claim airdrop rewards once a week.

### changeAirdropPercentage

```solidity
function changeAirdropPercentage(uint256 amount) external onlyOwner
```

This function allows the contract owner to change the percentage of airdrop rewards.

-   `amount`: The new airdrop percentage in basis point format (0.01%).

### claimAirdrop

```solidity
function claimAirdrop() external
```

This function allows a user to claim their airdrop rewards once a week.

### getStake

```solidity
function getStake(address _user) external view returns (StakingSummary memory)
```

This function allows users to get a summary of their staking details, including the total staked amount, penalty (if applicable), claimable rewards, and claimable airdrop rewards.

-   `_user`: The address of the user to retrieve staking details for.

### hasStake

```solidity
function hasStake(address _user) external view returns (bool)
```

This function allows users to check if they have an active stake.

-   `_user`: The address of the user to check for an active stake.

## Custom Errors

### FailedToSendEther

```solidity
FailedToSendEther()
```

This error occurs when the contract owner attempts to withdraw Ether from the contract, but the transaction fails.

### TaxLimitError

```solidity
TaxLimitError(bytes32 tax)
```

This error occurs when attempting to change the tax rate, but the provided tax amount exceeds the maximum limit of 5% (500 basis points).
