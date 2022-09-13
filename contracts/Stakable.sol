// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Stakable {
    using SafeMath for uint256;
    /**
     * @notice Constructor since this contract is not meant to be used without inheritance
     * push once to stakeholders for it to work properly
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

    address public _talax;
    address public _owner;

    constructor() {
        //Staking penalty and Airdrop in 0.1 times percentage
        stakingPenaltyRate = 15;
        airdropRate = 80;
        _talax = msg.sender;
        _owner = msg.sender;
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        uint256 amount;
        uint256 since;
        uint256 rewardAPY;
        uint256 releaseTime;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
        uint256 claimableAirdrop;
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
    mapping(address => Stake) internal stakeholders;

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

    /* ------------------------------------------ Modifier ------------------------------------------ */
    function isTalax() internal view {
        require(msg.sender == _talax, "Not authorized");
    }

    modifier onlyTalax() {
        isTalax();
        _;
    }

    function isOwner() internal view {
        require(msg.sender == _owner, "Not authorized");
    }

    modifier onlyOwner() {
        isOwner();
        _;
    }

    function _isVoter() internal view {
        require(voters[msg.sender].votingRight == true, "You are not a voter");
    }

    modifier isVoter() {
        _isVoter();
        _;
    }

    function _checkVotingStatus() internal view {
        require(_votingStatus, "Voting is not available");
    }

    modifier votingStatusTrue() {
        _checkVotingStatus();
        _;
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    function changeTalaxAddress(address talax) external onlyOwner {
        _talax = talax;
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
        require(stakeholders[user].amount == 0, "User is a staker");

        totalVoters += 1;
        voters[user].votingRight = true;

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.

        stakeholders[user] = Stake(
            amount,
            timestamp,
            rewardRate,
            (stakePeriod + timestamp),
            0,
            0,
            0
        );
        // Emit an event that the stake has occured
        emit Staked(user, amount, timestamp, (stakePeriod + timestamp));
    }

    function changePenaltyFee(uint256 amount) external onlyOwner {
        require(amount <= 30, "Penalty fee cannot exceed 3 percent.");
        stakingPenaltyRate = amount;
        emit PenaltyChanged(amount);
    }

    function _calculateStakingDuration(uint256 since)
        internal
        view
        returns (uint256)
    {
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

    function _calculateStakingWithPenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        if (amount == 0) {
            return (0, 0);
        }
        return (
            SafeMath.sub(
                amount,
                SafeMath.div(SafeMath.mul(amount, stakingPenaltyRate), 1000)
            ),
            SafeMath.sub(
                reward,
                SafeMath.div(SafeMath.mul(reward, stakingPenaltyRate), 1000)
            )
        );
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the account
     * Will also _calculateStakeReward and reset timer
     */
    function withdrawStake(address user)
        external
        onlyTalax
        returns (uint256, uint256)
    {
        //can be simplified
        // Grab user_index which is the index to use to grab the Stake[]
        Stake memory user_stake = stakeholders[user];

        delete stakeholders[user];

        if (user_stake.releaseTime > block.timestamp) {
            totalVoters -= 1;
            delete voters[user].voted[_votingId];
            return
                _calculateStakingWithPenalty(
                    user_stake.amount,
                    _calculateStakeReward(user_stake)
                );
        }

        totalVoters -= 1;
        delete voters[user].voted[_votingId];
        return (user_stake.amount, _calculateStakeReward(user_stake));
    }

    function hasStake() external view returns (StakingSummary memory) {
        Stake memory user_stake = stakeholders[msg.sender];
        require(user_stake.amount > 0, "No Stake Found");
        StakingSummary memory summary = StakingSummary(0, 0, user_stake);

        uint256 reward = _calculateStakeReward(user_stake);

        if (summary.stake.releaseTime > block.timestamp) {
            summary.penalty =
                SafeMath.div(
                    SafeMath.mul(user_stake.amount, stakingPenaltyRate),
                    1000
                ) +
                SafeMath.div(SafeMath.mul(reward, stakingPenaltyRate), 1000);
        }

        if (_calculateWeek(user_stake.latestClaimDrop) > 0) {
            uint256 airdrop = _calculateAirdrop(user_stake.amount);
            summary.stake.claimableAirdrop = airdrop;
        } else {
            summary.stake.claimableAirdrop = 0;
        }

        summary.stake.claimable = reward;
        summary.total_amount = user_stake.amount;

        return summary;
    }

    /* -------------------------------------- Airdrop functions ------------------------------------- */

    function startAirdropSince() external onlyTalax {
        airdropSince = block.timestamp;
    }

    function _calculateWeek(uint256 input) internal view returns (uint256) {
        return (block.timestamp - input).div(7 days);
    }

    function changeAirdropPercentage(uint256 amount) external onlyOwner {
        require(amount <= 200, "Airdrop Percentage cannot exceed 20 percent.");
        airdropRate = amount;
        emit AirdropChanged(amount);
    }

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
        //can be simplified if using address
        Stake memory staker = stakeholders[user];

        if (staker.amount > 0) {
            require(
                _calculateWeek(staker.latestClaimDrop) > 0,
                "Claimable once a week"
            );

            staker.claimableAirdrop = 0;
            staker.latestClaimDrop = block.timestamp;

            return _calculateAirdrop(staker.amount);
        } else {
            return 0;
        }
    }

    function airdropWeek() public view returns (uint256) {
        if (airdropSince != 0) {
            return (block.timestamp - airdropSince) / 7 days;
        } else {
            return 0;
        }
    }

    /* -------------------------------- Voting Functions for DAO Pool ------------------------------- */

    function getVoters(address user) external view returns (bool, bool) {
        return (voters[user].votingRight, voters[user].voted[_votingId]);
    }

    //can be simplified since not connected directly
    function startVoting() external onlyTalax {
        require(_votingStatus == false, "Voting is already running");
        _votingStatus = true;
        _votingId += 1;
    }

    function vote() public votingStatusTrue isVoter {
        require(
            voters[msg.sender].voted[_votingId] == false,
            "You have voted before"
        );

        voters[msg.sender].voted[_votingId] = true;
        votedUsers[_votingId] += 1;
    }

    function retractVote() public votingStatusTrue isVoter {
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
