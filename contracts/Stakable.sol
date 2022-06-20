// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Stakable {
    using SafeMath for uint256;
    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */

    uint256 private _stakingPenaltyRate;
    uint256 private _airdropRate;

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
        uint256 claimable_airdropRate;
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
        require(stakeholders[_user].stake.amount == 0,"User is a staker");

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
        require(
            amount_ <= 30,
            "Penalty fee cannot exceed 3 percent."
        );
        _stakingPenaltyRate = amount_;
        emit PenaltyChanged(amount_);
    }

    function _changeAirdropPercentage(uint256 amount_) internal {
        require(
            amount_ <= 200,
            "Airdrop Percentage cannot exceed 20 percent."
        );
        _airdropRate = amount_;
        emit AirdropChanged(amount_);
    }

    function penaltyFee() public view returns (uint256) {
        return _stakingPenaltyRate;
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

    function calculateStakingWithPenalty(uint256 amount, uint256 reward)
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
                SafeMath.div(SafeMath.mul(amount, _stakingPenaltyRate), 1000)
            ),
            SafeMath.sub(
                reward,
                SafeMath.div(SafeMath.mul(reward, _stakingPenaltyRate), 1000)
            )
        );
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(address _user) internal returns (uint256, uint256) {
        // Grab user_index which is the index to use to grab the Stake[]
        Stake storage stake = stakeholders[_user].stake;

        // Calculate available Reward first before we start modifying data
        uint256 amount = stake.amount;
        uint256 reward = calculateStakeReward(stake, stake.amount);

        /**
         * @notice This is penalty given for early withdrawal before the designated time
         */

        if (stake.releaseTime > block.timestamp) {
            delete stakeholders[_user];
            return calculateStakingWithPenalty(amount, reward);
        }

        delete stakeholders[_user];
        return (amount, reward);
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[_staker].stake
        );
        require(summary.stake.amount != 0, "No stake found");

        uint availableReward = calculateStakeReward(
            summary.stake,
            summary.stake.amount
        );

        summary.stake.claimable = availableReward;
        summary.total_amount = summary.stake.amount;

        return summary;
    }

    function _claimAirdrop(address _staker) internal returns (uint256) {
        Stakeholder storage stakeholder = stakeholders[_staker];
        uint256 monthAirdrop = (block.timestamp - stakeholder.latestClaimDrop)
            .div(7 days);

        require(
            monthAirdrop >= 1,
            "Claimable once a month"
        );

        require(stakeholder.stake.amount > 0, "No stake found");

        uint256 airdrop = ((stakeholder.stake.amount * _airdropRate) / 100);
        stakeholder.stake.claimable_airdropRate = airdrop;
        stakeholder.latestClaimDrop = block.timestamp;

        return airdrop;
    }
}
