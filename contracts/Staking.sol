// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice Error handling message for Modifier
 */
error Function__notAuthorized();

/**
 * @notice Error handling message for Staking functions
 */
error Staking__cannotStakeNothing();
error Staking__userIsStaker();
error Staking__penaltyExceed3Percent();
error Staking__airdropExceed20Percent();
error Staking__noStakingFound();
error Staking_noStakingPackageFound();

/**
 * @notice Error handling message for Airdrop functions
 */
error Airdrop__notStarted();
error Airdrop__claimableOnceAWeek();

contract Staking is ReentrancyGuard, Ownable {
    /**
     * @notice Constructor since this contract is not meant to be used without inheritance
     * push once to stakeholders for it to work properly
     */

    mapping(uint256 => uint256) internal stakingPackage;

    uint256 public stakingPenaltyRate;
    uint256 public airdropRate;
    uint256 public airdropSince;
    bool public airdropStatus;

    address public token_address;

    constructor(address token) {
        //Staking penalty and Airdrop in 0.1 times percentage
        stakingPenaltyRate = 15;
        airdropRate = 80;

        token_address = token;

        stakingPackage[90 days] = 6;
        stakingPackage[180 days] = 7;
        stakingPackage[365 days] = 8;
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

    function _checkAirdropStatus() internal view {
        if (!airdropStatus) {
            revert Airdrop__notStarted();
        }
    }

    modifier airdropStatusTrue() {
        _checkAirdropStatus();
        _;
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function stake(uint256 amount, uint256 stakePeriod) external nonReentrant {
        // Simple check so that user does not stake 0
        // require(amount > 0, "Cannot stake nothing");
        // require(stakeholders[user].amount == 0, "User is a staker");
        if (stakeholders[msg.sender].amount != 0) {
            revert Staking__userIsStaker();
        }

        if (stakingPackage[stakePeriod] == 0) {
            revert Staking_noStakingPackageFound();
        }

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.

        stakeholders[msg.sender] = Stake(
            amount,
            timestamp,
            stakingPackage[stakePeriod],
            (stakePeriod + timestamp),
            0,
            0,
            0
        );

        SafeERC20.safeTransferFrom(
            IERC20(token_address),
            msg.sender,
            address(this),
            amount
        );
        // Emit an event that the stake has occured
        emit Staked(msg.sender, amount, timestamp, (stakePeriod + timestamp));
    }

    function changePenaltyFee(uint256 amount) external onlyOwner {
        // require(amount <= 30, "Penalty fee cannot exceed 3 percent.");
        if (amount > 30) {
            revert Staking__penaltyExceed3Percent();
        }
        stakingPenaltyRate = amount;
        emit PenaltyChanged(amount);
    }

    function _calculateStakingDuration(uint256 since)
        internal
        view
        returns (uint256)
    {
        // times by 1e24 so theres no missing value
        return ((block.timestamp - since) * 1e24) / 365 days;
    }

    function _calculateStakeReward(Stake memory user_stake)
        internal
        view
        returns (uint256)
    {
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
        return (
            amount - ((amount * stakingPenaltyRate) / 1000),
            reward - ((reward * stakingPenaltyRate) / 1000)
        );
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the account
     * Will also _calculateStakeReward and reset timer
     */

    function withdrawStake() external nonReentrant {
        // TODO: can be simplified
        // Grab user_index which is the index to use to grab the Stake[]
        Stake memory user_stake = stakeholders[msg.sender];
        if (user_stake.amount == 0) {
            revert Staking__noStakingFound();
        }

        uint256 reward = _calculateStakeReward(user_stake);
        delete stakeholders[msg.sender];

        if (user_stake.releaseTime > block.timestamp) {
            (
                uint256 amount_reduced,
                uint256 reward_reduced
            ) = _calculateStakingWithPenalty(user_stake.amount, reward);

            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                (amount_reduced + reward_reduced)
            );
        } else {
            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                (user_stake.amount + reward)
            );
        }
    }

    function hasStake() external view returns (StakingSummary memory) {
        Stake memory user_stake = stakeholders[msg.sender];
        // require(user_stake.amount > 0, "No Stake Found");
        if (user_stake.amount == 0) {
            revert Staking__noStakingFound();
        }
        StakingSummary memory summary = StakingSummary(0, 0, user_stake);

        uint256 reward = _calculateStakeReward(user_stake);

        if (summary.stake.releaseTime > block.timestamp) {
            summary.penalty =
                ((user_stake.amount * stakingPenaltyRate) / 1000) +
                ((reward * stakingPenaltyRate) / 1000);
        }

        if (calculateWeek(user_stake.latestClaimDrop) > 0) {
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

    function startAirdrop() external onlyOwner {
        airdropSince = block.timestamp;
        airdropStatus = true;
    }

    function changeAirdropPercentage(uint256 amount) external onlyOwner {
        if (amount > 200) {
            revert Staking__airdropExceed20Percent();
        }
        airdropRate = amount;
        emit AirdropChanged(amount);
    }

    function blockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function calculateWeek(uint256 timestamp) public view returns (uint256) {
        return (block.timestamp - timestamp) / 7 days;
    }

    function _calculateAirdrop(uint256 stakeAmount)
        internal
        view
        returns (uint256)
    {
        return ((stakeAmount * airdropRate) / 1000) / 52 weeks;
    }

    function claimAirdrop() external airdropStatusTrue {
        // TODO: can be simplified if using address
        Stake storage staker = stakeholders[msg.sender];
        if (staker.amount == 0) {
            revert Staking__noStakingFound();
        }

        if (staker.amount > 0) {
            if (calculateWeek(staker.latestClaimDrop) == 0) {
                revert Airdrop__claimableOnceAWeek();
            }

            staker.claimableAirdrop = 0;
            staker.latestClaimDrop = block.timestamp;

            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                _calculateAirdrop(staker.amount)
            );
        }
    }
}
