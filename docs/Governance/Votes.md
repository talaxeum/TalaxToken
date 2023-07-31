# Votes Smart Contract Documentation

Table of Contents:

1. [Introduction](#introduction)
2. [Structs](#structs)
    - Proposal
3. [Events](#events)
    - ProposalCreated
    - ProposalVoted
    - ProposalExecuted
4. [Interfaces](#interfaces)
    - Token
    - Stakes
5. [Constructor](#constructor)
6. [Main Functions](#main-functions)
    - propose
    - vote
    - execute

## Introduction

The `Votes` smart contract is used to create and manage voting proposals. Users can propose new ideas, and other users can vote on them. The proposals can be voted by holders of Talax tokens or stakeholders, depending on the type of proposal.

## Structs

### `struct Proposal`

This struct represents a voting proposal. It contains information such as the total number of votes, the deadline for voting, the minimum count required to pass the proposal, the description of the proposal, whether the proposal has been executed, and whether the proposal requires being a DAO stakeholder.

## Events

### ProposalCreated

```solidity
event ProposalCreated(uint256 indexed voteId, bytes32 description)
```

This event is emitted when a new voting proposal is created.

### ProposalVoted

```solidity
event ProposalVoted(uint256 indexed voteId, address indexed user)
```

This event is emitted when a user votes on a proposal.

### ProposalExecuted

```solidity
event ProposalExecuted(uint256 indexed voteId, bytes32 description)
```

This event is emitted when a proposal is executed and passed.

## Interfaces

### `interface Token`

This interface is used for checking if a user holds Talax tokens.

### `interface Stakes`

This interface is used for checking if a user has stakes in a DAO.

## Constructor

```solidity
constructor(address _talax, address _stake)
```

The constructor initializes the `Votes` contract with the addresses of the Talax token contract and the DAO stake contract.

## Main Functions

### Propose

```solidity
function propose(bytes32 _description, uint256 _duration, uint256 _minCount, bool _isDao) external onlyOwner
```

This function allows the contract owner to create a new voting proposal. The description, duration, minimum vote count to pass the proposal, and whether the proposal is a DAO proposal are provided as input parameters.

-   `_description`: The description of this proposal
-   `_duration`: The duration of the voting process
-   `_minCount`: The minimum vote count to be valid
-   `_isDao`: The status of this vote

### Vote

```solidity
function vote(uint256 _voteId) external
```

This function allows users to vote on a specific proposal. Users must have the appropriate voting rights (Talax token holder or DAO stakeholder) to vote.

-   `_voteId`: The vote id

### Execute

```solidity
function execute(uint256 _voteId) public onlyOwner
```

This function allows the contract owner to execute a voting proposal after the voting period has ended and the minimum vote count has been reached.

-   `_voteId`: The vote id
