// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Token {
    function taxRate() external returns (uint256);
}

contract Staking is ReentrancyGuard, Ownable {
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

    address public token_address;
    uint256 public stakingPenaltyRate;
    uint256 public airdropRate;
    uint256 public airdropSince;
    bool public airdropStatus;
    mapping(uint256 => uint256) internal _stakingPackage;

    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        uint256 releaseTime
    );
    event StakeClaimed(
        address indexed user,
        uint256 claimed,
        uint256 timestamp
    );

    event PenaltyChanged(uint256 amount);
    event AirdropChanged(uint256 amount);

    /**
     * @notice Constructor since this contract is not meant to be used without inheritance
     * push once to stakeholders for it to work properly
     */
    constructor(address token) {
        //Staking penalty and Airdrop in 0.1 times percentage
        stakingPenaltyRate = 150; // bps
        airdropRate = 800; // bps

        token_address = token;

        // APY in bps
        _stakingPackage[90 days] = 600;
        _stakingPackage[180 days] = 700;
        _stakingPackage[365 days] = 800;
    }

    function changePenaltyFee(uint256 amount) external onlyOwner {
        // require(amount <= 30, "Penalty fee cannot exceed 3 percent.");
        require(amount <= 300, "Penalty max 3%");
        stakingPenaltyRate = amount;
        emit PenaltyChanged(amount);
    }

    /* ------------------------------------ Main Stake Functions ------------------------------------ */

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function stake(uint256 amount, uint256 stakePeriod) external nonReentrant {
        // Simple check so that user does not stake 0
        // require(stakeholders[user].amount == 0, "User is a staker");

        require(amount > 0, "Cannot stake nothing");
        require(stakeholders[msg.sender].amount == 0, "User is a Staker");
        require(_stakingPackage[stakePeriod] != 0, "Package not Found");

        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.

        uint256 amountIncludeTax = ((100 - Token(token_address).taxRate()) *
            amount) / 10_000;

        stakeholders[msg.sender] = Stake(
            amountIncludeTax,
            timestamp,
            _stakingPackage[stakePeriod],
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
        // Emit an event that the stake has occurred
        emit Staked(
            msg.sender,
            amountIncludeTax,
            timestamp,
            (stakePeriod + timestamp)
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
        // Grab user_index which is the index to use to grab the Stake[]
        Stake memory user_stake = stakeholders[msg.sender];
        require(user_stake.amount != 0, "Staking not found");

        uint256 reward = _calculateStakeReward(user_stake);
        delete stakeholders[msg.sender];

        if (user_stake.releaseTime > block.timestamp) {
            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                (_calculateStakingWithPenalty(user_stake.amount, reward))
            );
            emit StakeClaimed(
                msg.sender,
                _calculateStakingWithPenalty(user_stake.amount, reward),
                block.timestamp
            );
        } else {
            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                (user_stake.amount + reward)
            );
            emit StakeClaimed(
                msg.sender,
                (user_stake.amount + reward),
                block.timestamp
            );
        }
    }

    /* -------------------------------------- Airdrop functions ------------------------------------- */

    function startAirdrop() external onlyOwner {
        airdropSince = block.timestamp;
        airdropStatus = true;
    }

    function changeAirdropPercentage(uint256 amount) external onlyOwner {
        require(amount <= 2_000, "Airdrop max 20%");
        airdropRate = amount;
        emit AirdropChanged(amount);
    }

    function calculateWeek(uint256 timestamp) public view returns (uint256) {
        return (block.timestamp - timestamp) / 7 days;
    }

    function claimAirdrop() external {
        // Airdrop status need to be updated by admin first
        require(airdropStatus, "Not Initialized");
        Stake storage user_stake = stakeholders[msg.sender];

        require(user_stake.amount != 0, "Staking not found");
        uint256 latestClaim = calculateWeek(user_stake.latestClaimDrop);

        if (user_stake.amount > 0) {
            require(latestClaim != 0, "Claimable once a week");

            user_stake.claimableAirdrop = 0;
            user_stake.latestClaimDrop = block.timestamp;

            SafeERC20.safeTransfer(
                IERC20(token_address),
                msg.sender,
                _calculateAirdrop(user_stake.amount)
            );
        }
    }

    /* ----------------------------------------- Get Summary ---------------------------------------- */

    function hasStake() external view returns (StakingSummary memory) {
        Stake memory user_stake = stakeholders[msg.sender];
        require(user_stake.amount != 0, "Staking not found");
        StakingSummary memory summary = StakingSummary(0, 0, user_stake);

        uint256 reward = _calculateStakeReward(user_stake);

        if (summary.stake.releaseTime > block.timestamp) {
            summary.penalty = _calculateStakingWithPenalty(
                user_stake.amount,
                reward
            );
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

    /* -------------------------------------- Helpers Function -------------------------------------- */

    function _calculateStakingDuration(
        uint256 since
    ) internal view returns (uint256) {
        // times by 1e24 so theres no missing value
        return ((block.timestamp - since) * 1e24) / 365 days;
    }

    function _calculateStakeReward(
        Stake memory user_stake
    ) internal view returns (uint256) {
        // divided by 1e26 because 1e4 for APY and 1e24 from calculate staking duration
        return
            (user_stake.amount *
                user_stake.rewardAPY *
                _calculateStakingDuration(user_stake.since)) / 1e28;
    }

    function _calculateStakingWithPenalty(
        uint256 amount,
        uint256 reward
    ) internal view returns (uint256) {
        return
            ((amount * stakingPenaltyRate) / 10_000) +
            ((reward * stakingPenaltyRate) / 10_000);
    }

    function _calculateAirdrop(
        uint256 stakeAmount
    ) internal view returns (uint256) {
        return ((stakeAmount * airdropRate) / 10_000) / 52 weeks;
    }
}
