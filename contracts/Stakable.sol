// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Stakable {
    using SafeMath for uint256;
    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */

    uint256 public _stakingPenaltyRate;
    uint256 public _airdropRate;
    uint256 public airdropSince;

    constructor() {
        //Staking penalty and Airdrop in 0.1 times percentage
        _stakingPenaltyRate = 15;
        _airdropRate = 80;
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

    function _startAirdropSince() internal {
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
    function _stake(
        address _user,
        uint256 _amount,
        uint256 _stakePeriod,
        uint256 _rewardRate
    ) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");
        require(stakeholders[_user].stake.amount == 0, "User is a staker");

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[_user].stake = Stake(
            _user,
            _amount,
            timestamp,
            0,
            0,
            _rewardRate,
            (_stakePeriod + timestamp)
        );
        // Emit an event that the stake has occured
        emit Staked(_user, _amount, timestamp, (_stakePeriod + timestamp));
    }

    function _changePenaltyFee(uint256 amount_) internal {
        require(amount_ <= 30, "Penalty fee cannot exceed 3 percent.");
        _stakingPenaltyRate = amount_;
        emit PenaltyChanged(amount_);
    }

    function _changeAirdropPercentage(uint256 amount_) internal {
        require(amount_ <= 200, "Airdrop Percentage cannot exceed 20 percent.");
        _airdropRate = amount_;
        emit AirdropChanged(amount_);
    }

    function calculateStakingDuration(uint256 since_)
        internal
        view
        returns (uint256)
    {
        require(since_ > 0, "Error timestamp 0");
        return
            SafeMath.div(
                (block.timestamp - since_) * 1e24,
                365 days,
                "Error cannot divide timestamp"
            );
    }

    function calculateStakeReward(Stake memory user_stake, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if (user_stake.amount == 0) {
            return 0;
        }

        return
            (_amount *
                user_stake.rewardAPY *
                calculateStakingDuration(user_stake.since)) / 1e26;
    }

    function calculatePenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 amount_penalty = SafeMath.div(
            SafeMath.mul(amount, _stakingPenaltyRate),
            1000
        );
        uint256 reward_penalty = SafeMath.div(
            SafeMath.mul(reward, _stakingPenaltyRate),
            1000
        );

        return (amount_penalty, reward_penalty);
    }

    function calculateStakingWithPenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        if (amount == 0) {
            return (0, 0);
        }

        (uint256 amount_penalty, uint256 reward_penalty) = calculatePenalty(
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
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(address _user, uint256 _amount)
        internal
        returns (uint256, uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        Stake storage stake = stakeholders[_user].stake;

        uint256 reward = calculateStakeReward(stake, _amount);

        if (stake.amount == _amount) {
            delete stakeholders[_user];

            if (stake.releaseTime > block.timestamp) {
                return calculateStakingWithPenalty(_amount, reward);
            }

            return (_amount, reward);
        } else {
            stake.amount = stake.amount.sub(_amount);

            if (stake.releaseTime > block.timestamp) {
                return calculateStakingWithPenalty(_amount, reward);
            }

            return (_amount, reward);
        }
    }

    function _calculateAirdrop(uint256 stakeAmount)
        internal
        view
        returns (uint256)
    {
        uint256 airdrop = ((stakeAmount * _airdropRate) / 100);
        return airdrop;
    }

    function _claimAirdrop(address _staker) internal view returns (uint256) {
        Stakeholder memory stakeholder = stakeholders[_staker];

        require(stakeholder.stake.amount > 0, "No stake found");

        require(
            _calculateWeek(stakeholder.latestClaimDrop) > 0,
            "Claimable once a week"
        );

        uint256 airdrop = _calculateAirdrop(stakeholder.stake.amount);
        stakeholder.stake.claimable_airdrop = 0;
        stakeholder.latestClaimDrop = block.timestamp;

        return airdrop;
    }

    function airdropWeek() public view returns (uint256) {
        if (airdropSince != 0) {
            return (block.timestamp - airdropSince) / 7 days;
        } else {
            return 0;
        }
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        Stakeholder memory data = stakeholders[_staker];
        StakingSummary memory summary = StakingSummary(0, 0, data.stake);
        require(summary.stake.amount != 0, "No stake found");

        uint256 availableReward = calculateStakeReward(
            summary.stake,
            summary.stake.amount
        );
        uint256 penalty;

        if (summary.stake.releaseTime > block.timestamp) {
            (uint256 amount_penalty, uint256 reward_penalty) = calculatePenalty(
                summary.stake.amount,
                availableReward
            );
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
}
