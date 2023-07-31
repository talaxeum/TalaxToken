# Whitelist Smart Contract Documentation

## Table of Contents

1. [Constructor](#constructor)
2. [Events](#events)
3. [Functions](#functions)
    - [updateRoot](#updateroot)
    - [vest](#vest)
    - [release](#release)
    - [released](#released)
    - [releasable](#releasable)
    - [vestedAmount](#vestedamount)
4. [Internal Functions](#internal-functions)
    - [\_currentMonth](#currentmonth)
    - [\_delete](#delete)
    - [\_vestingSchedule](#vestingschedule)
5. [Merkle Proof Verification](#merkle-proof-verification)
6. [Example](#example)

The Whitelist smart contract handles the vesting of Ether and ERC20 tokens for a given beneficiary based on a Merkle proof. Custody of multiple tokens can be given to this contract, and the tokens will be released to the beneficiary following a given vesting schedule. The vesting schedule is customizable through the `vestedAmount` function.

Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning. Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly) be immediately releasable.

## Constructor

The constructor initializes the Whitelist contract with the vesting schedule parameters.

-   `start`: The timestamp when the vesting schedule starts.
-   `duration`: The duration of the vesting schedule in seconds.
-   `cliff`: The cliff period in seconds before the vesting schedule begins.

## Events

```solidity
ERC20Released(address indexed token, address indexed user, uint256 amount)
```

This event is triggered whenever ERC20 tokens are released to a beneficiary.

## Functions

### updateRoot

```solidity
function updateRoot(bytes32 _root) public onlyOwner
```

This function is used to update the Merkle root for the whitelist. It can only be called by the contract owner.

-   `_root`: The new Merkle root value.

### Vest

```solidity
function vest(address user, uint256 amount) public onlyOwner
```

This function is used to add a new user to the whitelist and vest tokens for them. It can only be called by the contract owner.

-   `user`: The address of the user to add to the whitelist.
-   `amount`: The amount of tokens to vest for the user.

### Release

```solidity
function release(bytes32[] calldata _proof) public virtual
```

This function allows a user to release their vested tokens by providing a valid Merkle proof.

-   `_proof`: The Merkle proof array.

### Released

```solidity
function released() public view virtual returns (uint256)
```

This function returns the total amount of tokens released to the caller.

### Releaseable

```solidity
function releasable() public view virtual returns (uint256)
```

This function calculates the amount of vested tokens that are available for release to the caller at the current timestamp.

### vestedAmount

```solidity
function vestedAmount(uint256 timestamp) public view virtual returns (uint256)
```

This function calculates the total vested amount of tokens for the caller at a given timestamp.

-   `timestamp`: The timestamp at which the vested amount is calculated.

## Internal Functions

### \_currentMonth

```solidity
function _currentMonth() internal view returns (uint256)
```

This internal function calculates the number of months that have passed since the vesting schedule started.

### \_delete

```solidity
function _delete(address _user) internal
```

This internal function is used to remove a user from the whitelist.

### \_vestingSchedule

```solidity
function _vestingSchedule(uint256 totalAllocation, uint256 timestamp) internal view virtual returns (uint256)
```

This internal function calculates the vested amount of tokens based on the vesting schedule.

-   `totalAllocation`: The total allocation of tokens held by the user at the given timestamp.
-   `timestamp`: The timestamp at which the vested amount is calculated.

## Merkle Proof Verification

The `release` function requires the caller to provide a valid Merkle proof to release their vested tokens. The Merkle proof should be constructed using the user's address as the leaf node. If the provided Merkle proof is valid against the current Merkle root, the tokens will be released to the caller.

## Example

Suppose the `Whitelist` contract is deployed with the following parameters:

-   `start`: `1662035034` (Unix timestamp representing a specific date)
-   `duration`: `180 days`
-   `cliff`: `30 days`

The contract owner can add users to the whitelist and vest tokens for them. Users can later release their vested tokens using a valid Merkle proof.
