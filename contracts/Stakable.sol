// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./src/SafeMath.sol";

contract Stakable {
    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */

    uint256 private _stakingPenalty;

    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
        _stakingPenalty = 5;
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
        uint256 rewardAPY;
        uint256 releaseTime;
    }
    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp,
        uint256 releaseTime
    );

    event PenaltyChanged(uint256 amount);

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function _stake(
        uint256 _amount,
        uint256 _stakePeriod,
        uint256 _rewardRate
    ) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Stakable: Cannot stake nothing");
        // require(_amount > 1e18, "Minimum stake is 1 TALAX");

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if (index == 0) {
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
        }

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(
            Stake(
                msg.sender,
                _amount,
                timestamp,
                0,
                _rewardRate,
                (_stakePeriod + timestamp)
            )
        );
        // Emit an event that the stake has occured
        emit Staked(
            msg.sender,
            _amount,
            index,
            timestamp,
            (_stakePeriod + timestamp)
        );
    }

    function _changePenaltyFee(uint256 amount_) internal {
        _stakingPenalty = amount_;
        emit PenaltyChanged(amount_);
    }

    function testCalculateDuration(uint256 index_, address user_)
        public
        view
        returns (uint256)
    {
        StakingSummary memory summary = stakeSummary(user_);

        return (block.timestamp - summary.stakes[index_].since);
    }

    function calculateStakingDuration(uint256 since_)
        internal
        view
        returns (uint256)
    {
        require(since_ > 0, "Stakable: Error timestamp 0");
        return
            SafeMath.div(
                (block.timestamp - since_) * 1e24,
                365 days,
                "Stakable: Error cannot divide timestamp"
            );
    }

    function calculateStakeReward(Stake memory _current_stake, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if (_current_stake.amount == 0) {
            return 0;
        }

        return
            (_amount *
                _current_stake.rewardAPY *
                calculateStakingDuration(_current_stake.since)) / 1e26;
    }

    function stakeSummary(address user_)
        public
        view
        returns (StakingSummary memory)
    {
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[user_]].address_stakes
        );

        return summary;
    }

    function calculateStakingPenalty(uint256 amount, uint256 reward)
        internal
        view
        returns (uint256, uint256)
    {
        if (amount == 0) {
            return (0, 0);
        }

        return (
            SafeMath.mul(amount, _stakingPenalty),
            SafeMath.mul(reward, _stakingPenalty)
        );
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 amount, uint256 index)
        internal
        returns (uint256, uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        // require(
        //     current_stake.releaseTime <= block.timestamp,
        //     "Stakable: Cannot withdraw before the release time"
        // );

        require(
            current_stake.amount >= amount,
            "Stakable: Cannot withdraw more than you have staked"
        );

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeReward(current_stake, amount);

        /**
         * @notice This is penalty given for early withdrawal before the designated time
         */

        if (current_stake.releaseTime < block.timestamp) {
            calculateStakingPenalty(amount, reward);
        }

        uint256 stakeDuration = current_stake.releaseTime - current_stake.since;
        // Remove by subtracting the money unstaked
        current_stake.amount = current_stake.amount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if (current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            stakeholders[user_index]
                .address_stakes[index]
                .amount = current_stake.amount;
            // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block
                .timestamp;
            stakeholders[user_index].address_stakes[index].releaseTime =
                block.timestamp +
                stakeDuration;
        }

        return (amount, reward);
    }

    function _withdrawAllStake(uint256 index)
        internal
        returns (uint256, uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        // require(
        //     current_stake.releaseTime <= block.timestamp,
        //     "Stakable: Cannot withdraw before the release time"
        // );

        require(
            current_stake.amount > 0,
            "Stakable: Cannot withdraw, you don't have any stake in this Index"
        );

        // Calculate available Reward first before we start modifying data
        uint256 amount = current_stake.amount;
        uint256 reward = calculateStakeReward(current_stake, amount);

        /**
         * @notice This is penalty given for early withdrawal before the designated time
         */

        if (current_stake.releaseTime < block.timestamp) {
            calculateStakingPenalty(amount, reward);
        }

        delete stakeholders[user_index].address_stakes[index];

        return (amount, reward);
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        uint256 totalStakeAmount;

        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        require(
            summary.stakes.length != 0,
            "Stakable: This address does not have any stakes"
        );

        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeReward(
                summary.stakes[s],
                summary.stakes[s].amount
            );
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
        }

        summary.total_amount = totalStakeAmount;
        return summary;
    }
}
