# Vesting Smart Contract Documentation

Table of Contents

1. [Constructor](#constructor)
2. [Events](#events)
3. [Functions](#functions)
    - [releasable](#releaseable)
    - [release](#release)
    - [vestedAmount](#vestedamount)
    - [\_vestingSchedule](#_vestingschedule)
4. [Vesting Schedule](#vesting-schedule)
5. [Example](#example)

The Vesting smart contract handles the vesting of Ether and ERC20 tokens for a given beneficiary. Multiple tokens can be given custody to this contract, which will release the tokens to the beneficiary following a customizable vesting schedule. The vesting schedule is based on the contract's start timestamp, duration, and cliff period.

## Constructor

The constructor initializes the Vesting contract.

-   `beneficiary`: The address of the beneficiary who will receive the vested tokens.
-   `start`: The timestamp when the vesting schedule starts.
-   `duration`: The duration of the vesting schedule in seconds.
-   `cliff`: The cliff period in seconds before the vesting schedule begins.

## Events

```solidity
ERC20Released(address indexed token, uint256 amount)
```

This event is triggered whenever ERC20 tokens are released to the beneficiary.

## Functions

### Releaseable

```solidity
function releasable() public view returns (uint256)
```

This function calculates the amount of vested tokens that are available for release at the current timestamp.

### Release

```solidity
function release() public virtual
```

This function releases the vested tokens to the beneficiary. It can be called by the beneficiary to claim their vested tokens.

### vestedAmount

```solidity
function vestedAmount(uint256 timestamp) public view virtual returns (uint256)
```

This function calculates the total vested amount of tokens at a given timestamp.

-   `timestamp`: The timestamp at which the vested amount is calculated.

### \_vestingSchedule

```solidity
function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view virtual returns (uint256)
```

This internal function calculates the vested amount of tokens based on the vesting schedule.

-   `totalAllocation`: The total allocation of tokens held by the contract at the given timestamp.
-   `timestamp`: The timestamp at which the vested amount is calculated.

## Vesting Schedule

The vesting schedule is based on a linear vesting model. The beneficiary's tokens will be locked until the `start` timestamp. After the `start` timestamp, the tokens will start vesting linearly, and the vesting will be completed by the end of the `duration` period.

The formula for calculating the vested amount at a given timestamp is as follows:

If the `timestamp` is before the `start`, the vested amount will be 0. If the `timestamp` is after the `start + duration`, the vested amount will be equal to the `totalAllocation`.

Note: The contract assumes that all ERC20 tokens are following the same vesting schedule as if they were locked from the beginning. Any token transferred to this contract will follow the vesting schedule, and vested amounts will be calculated accordingly.

## Example

Suppose the `Vesting` contract is deployed with the following parameters:

-   `beneficiary`: `0x123456789abcdef`
-   `start`: `1662035034` (Unix timestamp representing a specific date)
-   `duration`: `180 days`
-   `cliff`: `30 days`

The beneficiary's tokens will be locked until the timestamp `start + cliff` (30 days after the start). After the cliff period, the tokens will start vesting linearly over the next 180 days until the full `totalAllocation` is vested.
