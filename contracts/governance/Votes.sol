// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// For checking if the user hold talax token
interface Token {
    function balanceOf(address _user) external view returns (uint256);
}

// For checking if the user has stakes
interface Stakes {
    function hasStake(address _user) external view returns (bool);
}

contract Votes is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private voteIds;

    event ProposalCreated(uint256 indexed voteId, bytes32 description);
    event ProposalVoted(uint256 indexed voteId, address indexed user);
    event ProposalExecuted(uint256 indexed voteId, bytes32 description);

    struct Proposal {
        uint256 totalVote;
        uint256 deadline;
        // Need criteria to pass vote process
        uint256 minCount;
        bytes32 description;
        bool executed;
        bool isDao;
    }

    address talaxContract;
    address stakeContract;

    mapping(uint256 => Proposal) votes;

    constructor(address _talax, address _stake) {
        talaxContract = _talax;
        stakeContract = _stake;
    }

    function propose(
        bytes32 _description,
        uint256 _duration,
        uint256 _minCount,
        bool _isDao
    ) external onlyOwner {
        voteIds.increment();
        votes[voteIds.current()] = Proposal({
            totalVote: 0,
            description: _description,
            deadline: block.timestamp + _duration,
            minCount: _minCount,
            executed: false,
            isDao: _isDao
        });
    }

    function vote(uint256 _voteId) external {
        Proposal storage proposal = votes[_voteId];
        require(!proposal.executed, "Proposal was executed");

        // Check for the voting rights
        // If the proposal is Dao, check if the user has stakes
        // If the proposal is normal, check if the user is a holder of talax
        if (proposal.isDao) {
            require(Stakes(stakeContract).hasStake(msg.sender), "Not a Staker");
        } else {
            require(
                Token(talaxContract).balanceOf(msg.sender) > 0,
                "Not a holder"
            );
        }

        votes[_voteId].totalVote += 1;
    }

    function execute(uint256 _voteId) public onlyOwner {
        Proposal storage proposal = votes[_voteId];
        require(proposal.deadline < block.timestamp, "Proposal still running");
        require(proposal.totalVote > proposal.minCount, "Proposal Failed");

        proposal.executed = true;

        emit ProposalExecuted(_voteId, proposal.description);
    }
}
