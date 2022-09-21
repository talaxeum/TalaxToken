// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @notice Error handling message for Modifier
 */
error Function__notAuthorized();
error Function__notAVoter();
error Function__votingNotAvailable();

/**
 * @notice Error handling message for Staking functions
 */
error Staking__cannotStakeNothing();
error Staking__userIsStaker();
error Staking__penaltyExceed3Percent();
error Staking__airdropExceed20Percent();
error Staking__noStakingFound();

/**
 * @notice Error handling message for Airdrop functions
 */
error Airdrop__claimableOnceAWeek();

/**
 * @notice Error handling message for Voting functions
 */
error Voting__votingIsRunning();
error Voting__alreadyVoted();
error Voting__notYetVoted();
error Voting__notEnoughVoters();

contract Stakable is ReentrancyGuard {
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
        // require(msg.sender == _talax, "Not authorized");
        if (msg.sender != _talax) {
            revert Function__notAuthorized();
        }
    }

    modifier onlyTalax() {
        isTalax();
        _;
    }

    function isOwner() internal view {
        // require(msg.sender == _owner, "Not authorized");
        if (msg.sender != _owner) {
            revert Function__notAuthorized();
        }
    }

    modifier onlyOwner() {
        isOwner();
        _;
    }

    function _isVoter() internal view {
        // require(voters[msg.sender].votingRight == true, "You are not a voter");
        if (voters[msg.sender].votingRight == false) {
            revert Function__notAVoter();
        }
    }

    modifier isVoter() {
        _isVoter();
        _;
    }

    function _checkVotingStatus() internal view {
        // require(_votingStatus, "Voting is not available");
        if (!_votingStatus) {
            revert Function__votingNotAvailable();
        }
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
    ) external nonReentrant onlyTalax {
        // Simple check so that user does not stake 0
        // require(amount > 0, "Cannot stake nothing");
        if (amount <= 0) {
            revert Staking__cannotStakeNothing();
        }
        // require(stakeholders[user].amount == 0, "User is a staker");
        if (stakeholders[user].amount != 0) {
            revert Staking__userIsStaker();
        }

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
        nonReentrant
        onlyTalax
        returns (uint256, uint256)
    {
        // TODO: can be simplified
        // Grab user_index which is the index to use to grab the Stake[]
        Stake memory user_stake = stakeholders[user];

        delete stakeholders[user];
        totalVoters -= 1;
        delete voters[user].voted[_votingId];

        if (user_stake.releaseTime > block.timestamp) {
            return
                _calculateStakingWithPenalty(
                    user_stake.amount,
                    _calculateStakeReward(user_stake)
                );
        }

        return (user_stake.amount, _calculateStakeReward(user_stake));
    }

    function hasStake() external view returns (StakingSummary memory) {
        Stake memory user_stake = stakeholders[msg.sender];
        // require(user_stake.amount > 0, "No Stake Found");
        if (user_stake.amount <= 0) {
            revert Staking__noStakingFound();
        }
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

    function changeAirdropPercentage(uint256 amount) external onlyOwner {
        if (amount > 200) {
            revert Staking__airdropExceed20Percent();
        }
        airdropRate = amount;
        emit AirdropChanged(amount);
    }

    function _calculateWeek(uint256 input) internal view returns (uint256) {
<<<<<<< HEAD
        // return (block.timestamp - input).div(7 days);
        return (block.timestamp - input).div(1 minutes);
=======
        return (block.timestamp - input) / 7 days;
>>>>>>> dev_split
    }

    function _calculateAirdrop(uint256 stakeAmount)
        internal
        view
        returns (uint256)
    {
        return ((stakeAmount * airdropRate) / 1000) / 52 weeks;
    }

    function claimAirdrop(address user) external returns (uint256) {
        // TODO: can be simplified if using address
        Stake storage staker = stakeholders[user];

        if (staker.amount > 0) {
            if (_calculateWeek(staker.latestClaimDrop) == 0) {
                revert Airdrop__claimableOnceAWeek();
            }

            uint256 airdrop = _calculateAirdrop(staker.amount);

            staker.claimableAirdrop = 0;
            staker.latestClaimDrop = block.timestamp;

            return airdrop;
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
    function startVoting() external nonReentrant onlyTalax {
        // require(_votingStatus == false, "Voting is already running");
        if (_votingStatus == true) {
            revert Voting__votingIsRunning();
        }

        _votingStatus = true;
        _votingId += 1;
    }

    function vote() public nonReentrant votingStatusTrue isVoter {
        // require(
        //     voters[msg.sender].voted[_votingId] == false,
        //     "You have voted before"
        // );
        if (voters[msg.sender].voted[_votingId] == true) {
            revert Voting__alreadyVoted();
        }

        voters[msg.sender].voted[_votingId] = true;
        votedUsers[_votingId] += 1;
    }

    function retractVote() public nonReentrant votingStatusTrue isVoter {
        // require(
        //     voters[msg.sender].voted[_votingId] == true,
        //     "You have not voted yet"
        // );
        if (voters[msg.sender].voted[_votingId] == false) {
            revert Voting__notYetVoted();
        }

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
        // require(totalVoters > 1, "Not enough voters");
        if (totalVoters <= 1) {
            revert Voting__notEnoughVoters();
        }
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
