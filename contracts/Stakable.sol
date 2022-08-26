// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

error Voting___votingStatus();

contract Stakable {
    using SafeMath for uint256;
    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */

    struct Voter {
        bool votingRight;
        mapping(uint256 => bool) voted;
    }

    uint256 public stakingPenaltyRate;
    uint256 public airdropRate;
    uint256 public airdropSince;

    bool internal _votingStatus;
    uint256 internal _votingId;
    uint256 public totalVoters;
    mapping(address => Voter) public voters;
    mapping(uint256 => uint256) public votedUsers;

    address talaxAddress;

    constructor() {
        //Staking penalty and Airdrop in 0.1 times percentage
        stakingPenaltyRate = 15;
        airdropRate = 80;
        talaxAddress = msg.sender;
    }

    /* ------------------------------------------ Modifier ------------------------------------------ */
    function isTalax() internal view {
        require(msg.sender == talaxAddress, "Not authorized");
    }

    modifier onlyTalax() {
        isTalax();
        _;
    }

    function _checkUserStake(uint256 amount) internal pure {
        require(amount > 0, "No Stake Found");
    }

    function _checkVotingStatus() internal view {
        require(_votingStatus, "Voting is not available");
    }

    modifier votingStatusTrue() {
        _checkVotingStatus();
        _;
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
        uint256 claimable_airdrop;
        uint256 rewardAPY;
        uint256 releaseTime;
    }
    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        Stake stake;
        address user;
        uint256 latestClaimDrop;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        uint256 penalty;
        Stake stake;
    }

    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => Stakeholder) internal stakeholders;

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        uint256 releaseTime
    );

    event PenaltyChanged(uint256 amount);
    event AirdropChanged(uint256 amount);

    function setTalaxAddress(address talax) external onlyTalax {
        talaxAddress = talax;
    }

    function getVoters(address user) external view returns (bool, bool) {
        return (voters[user].votingRight, voters[user].voted[_votingId]);
    }

    function startAirdropSince() external onlyTalax {
        airdropSince = block.timestamp;
    }

    function _calculateWeek(uint256 input) internal view returns (uint256) {
        return (block.timestamp - input).div(7 days);
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function stake(
        address user,
        uint256 amount,
        uint256 stakePeriod,
        uint256 rewardRate
    ) external onlyTalax {
        // Simple check so that user does not stake 0
        require(amount > 0, "Cannot stake nothing");
        require(stakeholders[user].stake.amount == 0, "User is a staker");

        totalVoters += 1;
        voters[user].votingRight = true;

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[user].stake = Stake(
            user,
            amount,
            timestamp,
            0,
            0,
            rewardRate,
            (stakePeriod + timestamp)
        );
        // Emit an event that the stake has occured
        emit Staked(user, amount, timestamp, (stakePeriod + timestamp));
    }

    function changePenaltyFee(uint256 amount) external onlyTalax {
        require(amount <= 30, "Penalty fee cannot exceed 3 percent.");
        stakingPenaltyRate = amount;
        emit PenaltyChanged(amount);
    }

    function changeAirdropPercentage(uint256 amount) external onlyTalax {
        require(amount <= 200, "Airdrop Percentage cannot exceed 20 percent.");
        airdropRate = amount;
        emit AirdropChanged(amount);
    }

    function _calculateStakingDuration(uint256 since)
        internal
        view
        returns (uint256)
    {
        require(since > 0, "Error timestamp 0");

        // times by 1e24 so theres no missing value
        return
            SafeMath.div(
                (block.timestamp - since) * 1e24,
                365 days,
                "Error cannot divide timestamp"
            );
    }

    function _calculateStakeReward(Stake memory user_stake)
        internal
        view
        returns (uint256)
    {
        if (user_stake.amount == 0) {
            return 0;
        }
        // divided by 1e26 because 1e2 for APY and 1e24 from calculate staking duration
        return
            (user_stake.amount *
                user_stake.rewardAPY *
                _calculateStakingDuration(user_stake.since)) / 1e26;
    }

    function _calculatePenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        return (
            SafeMath.div(SafeMath.mul(amount, stakingPenaltyRate), 1000),
            SafeMath.div(SafeMath.mul(reward, stakingPenaltyRate), 1000)
        );
    }

    function _calculateStakingWithPenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        if (amount == 0) {
            return (0, 0);
        }

        (uint256 amount_penalty, uint256 reward_penalty) = _calculatePenalty(
            amount,
            reward
        );
        return (
            SafeMath.sub(amount, amount_penalty),
            SafeMath.sub(reward, reward_penalty)
        );
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also _calculateStakeReward and reset timer
     */
    function withdrawStake(address user)
        external
        onlyTalax
        returns (uint256, uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        Stake memory user_stake = stakeholders[user].stake;

        uint256 reward = _calculateStakeReward(user_stake);

        delete stakeholders[user];

        if (user_stake.releaseTime > block.timestamp) {
            totalVoters -= 1;
            delete voters[user].voted[_votingId];
            return _calculateStakingWithPenalty(user_stake.amount, reward);
        }

        totalVoters -= 1;
        delete voters[user].voted[_votingId];
        return (user_stake.amount, reward);
    }

    function hasStake() external view returns (StakingSummary memory) {
        Stakeholder memory data = stakeholders[msg.sender];
        StakingSummary memory summary = StakingSummary(0, 0, data.stake);
        _checkUserStake(summary.stake.amount);

        uint256 availableReward = _calculateStakeReward(summary.stake);
        uint256 penalty;

        if (summary.stake.releaseTime > block.timestamp) {
            (
                uint256 amount_penalty,
                uint256 reward_penalty
            ) = _calculatePenalty(summary.stake.amount, availableReward);
            penalty = amount_penalty + reward_penalty;
        }

        if (_calculateWeek(data.latestClaimDrop) > 0) {
            uint256 airdrop = _calculateAirdrop(summary.stake.amount);
            summary.stake.claimable_airdrop = airdrop;
        } else {
            summary.stake.claimable_airdrop = 0;
        }

        summary.stake.claimable = availableReward;
        summary.penalty = penalty;
        summary.total_amount = summary.stake.amount;

        return summary;
    }

    /* -------------------------------------- Airdrop functions ------------------------------------- */
    function _calculateAirdrop(uint256 stakeAmount)
        internal
        view
        returns (uint256)
    {
        return ((stakeAmount * airdropRate) / 1000) / 52 weeks;
    }

    function claimAirdrop(address user)
        external
        view
        onlyTalax
        returns (uint256)
    {
        Stakeholder memory stakeholder = stakeholders[user];

        _checkUserStake(stakeholder.stake.amount);

        require(
            _calculateWeek(stakeholder.latestClaimDrop) > 0,
            "Claimable once a week"
        );

        stakeholder.stake.claimable_airdrop = 0;
        stakeholder.latestClaimDrop = block.timestamp;

        return _calculateAirdrop(stakeholder.stake.amount);
    }

    function airdropWeek() public view returns (uint256) {
        if (airdropSince != 0) {
            return (block.timestamp - airdropSince) / 7 days;
        } else {
            return 0;
        }
    }

    /* -------------------------------- Voting Functions for DAO Pool ------------------------------- */
    function startVoting() external onlyTalax {
        require(_votingStatus == false, "Voting is already running");
        _votingStatus = true;
        _votingId += 1;
    }

    function isVoter(address user) public view returns (bool) {
        require(user != address(0), "Invalid address");

        return voters[user].votingRight;
    }

    function vote() public votingStatusTrue {
        require(voters[msg.sender].votingRight == true, "You are not a voter");
        require(
            voters[msg.sender].voted[_votingId] == false,
            "You have voted before"
        );

        voters[msg.sender].voted[_votingId] = true;
        votedUsers[_votingId] += 1;
    }

    function retractVote() public votingStatusTrue {
        require(voters[msg.sender].votingRight == true, "You are not a voter");
        require(
            voters[msg.sender].voted[_votingId] == true,
            "You have not voted yet"
        );

        voters[msg.sender].voted[_votingId] == false;
        votedUsers[_votingId] -= 1;
    }

    function getVotingResult()
        external
        view
        onlyTalax
        votingStatusTrue
        returns (bool)
    {
        require(totalVoters > 1, "Not enough voters");
        uint256 half_voters = SafeMath.div(SafeMath.mul(totalVoters, 5), 10);

        if (votedUsers[_votingId] > half_voters) {
            return true;
        } else {
            return false;
        }
    }

    function stopVoting() external onlyTalax votingStatusTrue {
        _votingStatus = false;
    }
}
