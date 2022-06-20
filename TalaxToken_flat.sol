
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/Multilockable.sol


pragma solidity 0.8.11;


contract Multilockable {
    using SafeMath for uint256;
    uint256 public totalUser;

    uint256 public totalAmount = 14679 * 1e3 * 1e18;
    uint256 public constant phase_1_total = 1467900 * 1e18;
    uint256 public constant phase_2_total = 36195 * 1e18;

    uint256 public _startPrivateSale;

    struct Multilock {
        uint256 lockedAmount;
        uint256 amount;
        bool phase_1_claimed;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => Multilock) private beneficiary;

    constructor() {}

    function _initiatePrivateSale() internal {
        _startPrivateSale = block.timestamp;
    }

    function hasMultilockable() external view returns (Multilock memory) {
        require(
            beneficiary[msg.sender].amount != 0,
            "PrivateSale: You don't have any balance for private sale"
        );
        return beneficiary[msg.sender];
    }

    /**
     *  @dev 		Main Functions
     *  @return 	Claimable amount from Locked Wallet
     */
    function _calculateClaimableAmount(address user)
        internal
        returns (uint256)
    {
        uint256 claimable;

        uint256 lockDuration = (block.timestamp - _startPrivateSale) / 1 days;

        //Phase 1 of locked wallet release - monthly
        if (lockDuration < 16 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_1_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
                beneficiary[user].phase_1_claimed = true;
            }
            beneficiary[user].latestClaimDay = 15 * 30;
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration >= 16 * 30 && lockDuration < 28 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_1_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
                beneficiary[user].phase_1_claimed = true;
            }

            uint256 sinceLatestClaim = lockDuration -
                beneficiary[user].latestClaimDay;
            claimable =
                sinceLatestClaim *
                claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_2_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
            beneficiary[user].latestClaimDay = lockDuration;
        }

        require(claimable != 0, "PrivateSale: There's nothing to claim yet");
        return claimable;
    }

    function _addBeneficiary(address user_, uint256 amount_) internal {
        require(
            amount_ <= totalAmount,
            "PrivateSale: not enough balance to add a new user"
        );
        require(
            beneficiary[user_].amount == 0,
            "PrivateSale: This user already registered"
        );
        beneficiary[user_].lockedAmount = amount_;
        beneficiary[user_].amount = amount_;
        beneficiary[user_].phase_1_claimed = false;
        beneficiary[user_].latestClaimDay = 1;

        totalUser += 1;
        totalAmount -= amount_;
    }

    function _deleteBeneficiary(address user_) internal returns (uint256) {
        require(
            beneficiary[user_].amount != 0,
            "PrivateSale: This user doesnt exist"
        );
        totalUser -= 1;
        totalAmount += beneficiary[user_].amount;
        uint256 ex_amount = beneficiary[user_].amount;

        delete beneficiary[user_];
        return ex_amount;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function _releaseClaimable(address user_) internal returns (uint256) {
        require(beneficiary[user_].amount > 0, "PrivateSale: no tokens left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(user_);

        require(claimableLockedAmount > 0, "PrivateSale: no tokens to release");

        beneficiary[user_].amount = SafeMath.sub(
            beneficiary[user_].amount,
            claimableLockedAmount,
            "PrivateSale: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}

// File: contracts/Lockable.sol


pragma solidity 0.8.11;


contract Lockable {
    uint256 private _amount;

    address public owner;
    // beneficiary of tokens after they are released
    address private immutable _beneficiary;

    uint256 private _startLockedWallet;

    uint256 private _latestClaimMonth;

    constructor(uint256 amount_, address beneficiary_) {
        require(amount_ > 0, "Lockable: Amount must greater than zero");
        _amount = amount_;
        _beneficiary = beneficiary_;
        _startLockedWallet = block.timestamp;
        owner = msg.sender;
    }

    /**
     * @dev modifier functions
     */

    modifier onlyTalax() {
        require(
            msg.sender == owner,
            "Lockable: caller have to be TalaxToken Smart Contract"
        );
        _;
    }

    /**
     * @dev Helper functions
     */
    function amount() external view returns (uint256) {
        return _amount;
    }

    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    function sender() external view returns (address) {
        return msg.sender;
    }

    /**
     * @notice Initiate Locked Wallet
     */

    function initiateLockedWallet() external {
        _startLockedWallet = block.timestamp;
    }

    /**
     *  @dev 		Main Functions
     *  @return 	Claimable amount from Locked Wallet
     */
    function _calculateClaimableAmount(uint256[55] memory amount_)
        internal
        returns (uint256)
    {
        uint256 months = (block.timestamp - _startLockedWallet) / 30 days;
        uint256 claimable;

        for (uint256 i = _latestClaimMonth; i <= 55; i++) {
            claimable = SafeMath.add(claimable, amount_[i]);
        }

        _latestClaimMonth = months + 1;

        require(claimable != 0, "Lockable: There's nothing to claim yet");
        return claimable;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable(uint256[55] memory amount_)
        external
        onlyTalax
        returns (uint256)
    {
        require(_amount > 0, "Lockable: no tokens left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(amount_);

        require(claimableLockedAmount > 0, "Lockable: no tokens to release");

        _amount = SafeMath.sub(
            _amount,
            claimableLockedAmount,
            "Lockable: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}

// File: contracts/Stakable.sol


pragma solidity 0.8.11;


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

    /* ------------------------------------------ Accessor ------------------------------------------ */
    function getAPY(address _staker) public view returns (uint256) {
        require(stakeholders[_staker].stake.amount > 0, "No stake found");
        return stakeholders[_staker].stake.rewardAPY;
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
        require(_amount > 0, "Stakable: Cannot stake nothing");

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
            "Stakable: Penalty fee cannot exceed 3 percent."
        );
        _stakingPenaltyRate = amount_;
        emit PenaltyChanged(amount_);
    }

    function _changeAirdropPercentage(uint256 amount_) internal {
        require(
            amount_ <= 200,
            "Stakable: Airdrop Percentage cannot exceed 20 percent."
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
        require(since_ > 0, "Stakable: Error timestamp 0");
        return
            SafeMath.div(
                (block.timestamp - since_) * 1e24,
                365 days,
                "Stakable: Error cannot divide timestamp"
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
            "Stakable: Airdrop can only be claimed in a month timespan"
        );

        require(stakeholder.stake.amount > 0, "No stake found");

        uint256 airdrop = ((stakeholder.stake.amount * _airdropRate) / 100);
        stakeholder.stake.claimable_airdropRate = airdrop;
        stakeholder.latestClaimDrop = block.timestamp;

        return airdrop;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: contracts/TalaxToken.sol


pragma solidity 0.8.11;








contract TalaxToken is ERC20, ERC20Burnable, Ownable, Stakable, Multilockable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(uint256 => uint256) internal _stakingPackage;
    uint256 public _stakingReward;
    uint256 public _privateSale;
    bool public _airdropStatus;
    bool public lockedWalletStatus;
    bool public privateSaleStatus;

    uint16 public _taxFee;

    /* ------------------------------------------ Addresses ----------------------------------------- */

    address private timelockController;

    /**
     * Local (in this smart contract)
     * address staking_reward_address;
     * address liquidity_reserve_address;
     */

    address public constant public_sale_address =
        0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
    address public constant private_placement_address =
        0x07A20dc6722563783e44BA8EDCA08c774621125E;
    address public constant dev_pool_address_1 =
        0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
    address public constant dev_pool_address_2 =
        0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
    address public constant dev_pool_address_3 =
        0x126974fa373267d86fAB6d6871Afe62ccB68e810;
    address public constant strategic_partner_address_1 =
        0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    address public constant strategic_partner_address_2 =
        0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    address public constant strategic_partner_address_3 =
        0xAeB26fB84d0E2b3B353Cd50f0A29FD40C916d2Ab;
    address public constant team_and_project_coordinator_address_1 =
        0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
    address public constant team_and_project_coordinator_address_2 =
        0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
    address public constant team_and_project_coordinator_address_3 =
        0x97620dEAdC98bC8173303686037ce7B986CF53C3;

    /* ------------------------------------------ Lockable ------------------------------------------ */

    Lockable private privatePlacementLockedWallet;
    Lockable private devPoolLockedWallet_1;
    Lockable private devPoolLockedWallet_2;
    Lockable private devPoolLockedWallet_3;
    Lockable private strategicPartnerLockedWallet_1;
    Lockable private strategicPartnerLockedWallet_2;
    Lockable private strategicPartnerLockedWallet_3;
    Lockable private teamAndProjectCoordinatorLockedWallet_1;
    Lockable private teamAndProjectCoordinatorLockedWallet_2;
    Lockable private teamAndProjectCoordinatorLockedWallet_3;

    struct Beneficiary {
        address user;
        uint256 amount;
    }

    constructor() ERC20("TALAXEUM", "TALAX") {
        _totalSupply = 210 * 1e6 * 1e18;
        _name = "TALAXEUM";
        _symbol = "TALAX";

        // later divided by 100 to make percentage
        _taxFee = 1;

        _airdropStatus = false;

        // Staking APY in percentage
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[360 days] = 8;

        /**
         * Amount Initialization
         */

        // _balances[address(this)] = 52500 * 1e3 * 1e18;
        _balances[msg.sender] = 52500 * 1e3 * 1e18;
        _stakingReward = 17514 * 1e3 * 1e18;

        // Public Sale
        _balances[public_sale_address] = 2310 * 1e3 * 1e18;

        // Private Sale
        // privateSaleLockedWallet = new Multilockable(14679 * 1e3 * 1e18);
        _privateSale = 14679 * 1e3 * 1e18;

        /**
         * Locked Wallet Initialization
         */

        privatePlacementLockedWallet = new Lockable(
            6993 * 1e3 * 1e18,
            private_placement_address
        );

        devPoolLockedWallet_1 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_1
        );
        devPoolLockedWallet_2 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_2
        );
        devPoolLockedWallet_3 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_3
        );

        strategicPartnerLockedWallet_1 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_1
        );
        strategicPartnerLockedWallet_2 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_2
        );
        strategicPartnerLockedWallet_3 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_3
        );

        teamAndProjectCoordinatorLockedWallet_1 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_1
        );
        teamAndProjectCoordinatorLockedWallet_2 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_2
        );
        teamAndProjectCoordinatorLockedWallet_3 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_3
        );

        //Public Sale, Private Sale, Private Placement, Staking Reward
        // Dev Pool, Strategic Partner, Team and Project Coordinator
        _totalSupply = _totalSupply.sub(
            157500 * 1e3 * 1e18,
            "Insufficient Total Supply"
        );
    }

    fallback() external payable {
        // Add any ethers send to this address to team and project coordinators addresses
        _addThirdOfValue(msg.value);
    }

    receive() external payable {
        _addThirdOfValue(msg.value);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             EVENTS                                             */
    /* ---------------------------------------------------------------------------------------------- */

    event ChangeTax(address indexed who, uint256 amount);
    event ChangeAirdropStatus(address indexed who, bool status);
    event ChangePenaltyFee(address indexed from, uint256 amount);
    event ChangeAirdropPercentage(address indexed from, uint256 amount);

    event AddPrivateSale(
        address indexed from,
        address indexed who,
        uint256 amount
    );
    event DeletePrivateSale(address indexed from, address indexed who);

    event InitiatePrivateSale(address indexed from);
    event InitiateLockedWallet(address indexed from);

    event TransferStakingReward(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            MODIFIERS                                           */
    /* ---------------------------------------------------------------------------------------------- */

    modifier lockedWalletInitiated() {
        require(lockedWalletStatus == true, "Locked Wallet not yet started");
        _;
    }

    modifier onlyWalletOwner(address walletOwner) {
        require(_msgSender() == walletOwner, "Wallet owner only");
        _;
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                       INTERNAL FUNCTIONS                                       */
    /* ---------------------------------------------------------------------------------------------- */

    /**
     * @dev this is the release rate for partial token release
     */
    function privatePlacementReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ];
    }

    function devPoolReleaseAmount() internal pure returns (uint256[55] memory) {
        return [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function strategicPartnerReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function teamAndProjectCoordinatorReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(105000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function _addThirdOfValue(uint256 amount_) internal {
        uint256 thirdOfValue = SafeMath.div(amount_, 3);
        _balances[team_and_project_coordinator_address_1] = _balances[
            team_and_project_coordinator_address_1
        ].add(thirdOfValue);

        _balances[team_and_project_coordinator_address_2] = _balances[
            team_and_project_coordinator_address_2
        ].add(thirdOfValue);

        _balances[team_and_project_coordinator_address_3] = _balances[
            team_and_project_coordinator_address_3
        ].add(thirdOfValue);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 tax = SafeMath.div(SafeMath.mul(amount, _taxFee), 100);
        uint256 taxedAmount = SafeMath.sub(amount, tax);

        uint256 teamFee = SafeMath.div(SafeMath.mul(taxedAmount, 2), 10);
        uint256 liquidityFee = SafeMath.div(SafeMath.mul(taxedAmount, 8), 10);

        _addThirdOfValue(teamFee);
        _balances[address(this)] = _balances[address(this)].add(liquidityFee);

        _balances[to] = _balances[to].add(taxedAmount);
        emit Transfer(from, to, taxedAmount);
    }

    /**
     * @notice ERC20 FUNCTIONS
     */

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @notice EXTERNAL FUNCTIONS
     */

    /**
     * @dev Creates 'amount_' of token into _stakingReward and liduidityReserve
     * @dev Deletes 'amount_' of token from _stakingReward
     * @dev Change '_taxFee' with 'taxFee_'
     */

    function mintStakingReward(uint256 amount_) public onlyOwner {
        _stakingReward = _stakingReward.add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit TransferStakingReward(address(0), address(this), amount_);
    }

    function mintLiquidityReserve(uint256 amount_) public onlyOwner {
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), address(this), amount_);
    }

    function burnStakingReward(uint256 amount_) external onlyOwner {
        _stakingReward = _stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit TransferStakingReward(address(this), address(0), amount_);
    }

    function burnLiquidityReserve(uint256 amount_) external onlyOwner {
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(address(this), address(0), amount_);
    }

    function changeTaxFee(uint16 taxFee_) external onlyOwner {
        require(taxFee_ < 5, "Tax Fee maximum is 5%");
        _taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }

    function changeAirdropStatus(bool status_) external onlyOwner {
        _airdropStatus = status_;
        emit ChangeAirdropStatus(_msgSender(), status_);
    }

    function changePenaltyFee(uint256 penaltyFee_) external onlyOwner {
        _changePenaltyFee(penaltyFee_);
        emit ChangePenaltyFee(_msgSender(), penaltyFee_);
    }

    function changeAirdropPercentage(uint256 airdrop_) external onlyOwner {
        _changeAirdropPercentage(airdrop_);
        emit ChangeAirdropPercentage(_msgSender(), airdrop_);
    }

    /* ------------------------ Stake function with burn function ------------------------ */
    function stake(uint256 _amount, uint256 _stakePeriod) external {
        // Make sure staker actually is good for it
        require(
            _stakePeriod == 30 days ||
                _stakePeriod == 90 days ||
                _stakePeriod == 180 days ||
                _stakePeriod == 365 days,
            "Staking option doesnt exist"
        );

        _stake(
            msg.sender,
            _amount,
            _stakePeriod,
            _stakingPackage[_stakePeriod]
        );
        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);
        // Stake amount goes to liquidity reserve
        _balances[address(this)] = _balances[address(this)].add(_amount);
    }

    /* ---- withdrawStake is used to withdraw stakes from the account holder ---- */
    function withdrawStake() external {
        (uint256 amount_, uint256 reward_) = _withdrawStake(msg.sender);
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintStakingReward(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _stakingReward = _stakingReward.sub(reward_);
        _totalSupply = _totalSupply.add(amount_ + reward_);
        _balances[_msgSender()] = _balances[_msgSender()].add(
            amount_ + reward_
        );
    }

    function claimAirdrop() external {
        require(_airdropStatus == true, "Airdrop not yet started");
        uint256 airdrop = _claimAirdrop(_msgSender());
        _balances[address(this)] = _balances[address(this)].sub(airdrop);
        _balances[_msgSender()] = _balances[_msgSender()].add(airdrop);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Locked Wallet                               */
    /* -------------------------------------------------------------------------- */
    function initiateLockedWallet_PrivateSale() external onlyOwner {
        require(
            lockedWalletStatus == false && privateSaleStatus == false,
            "Nothing to initialize"
        );
        lockedWalletStatus = true;
        privatePlacementLockedWallet.initiateLockedWallet();
        devPoolLockedWallet_1.initiateLockedWallet();
        devPoolLockedWallet_2.initiateLockedWallet();
        devPoolLockedWallet_3.initiateLockedWallet();
        strategicPartnerLockedWallet_1.initiateLockedWallet();
        strategicPartnerLockedWallet_2.initiateLockedWallet();
        strategicPartnerLockedWallet_3.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_1.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_2.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_3.initiateLockedWallet();
        emit InitiateLockedWallet(_msgSender());

        privateSaleStatus = true;
        _initiatePrivateSale();
        emit InitiatePrivateSale(_msgSender());
    }

    /* ---------------------------- Private Placement --------------------------- */
    function unlockPrivatePlacementWallet()
        external
        lockedWalletInitiated
        onlyWalletOwner(privatePlacementLockedWallet.beneficiary())
    {
        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------- Dev Pool -------------------------------- */
    function unlockDevPoolWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_1.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_2.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_3.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------------- Strategic Partner --------------------------- */
    function unlockStrategicPartnerWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_1
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_2
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_3
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------- Team and Project Coordinator ---------------------- */
    function unlockTeamAndProjectCoordinatorWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Private Sale                                */
    /* -------------------------------------------------------------------------- */

    // function addBeneficiary(address user, uint256 amount) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     require(amount > 0, "Cannot add beneficiary with 0 amount");
    //     _privateSale -= amount;
    //     _addBeneficiary(user, amount);
    //     emit AddPrivateSale(msg.sender, user, amount);
    // }

    function addMultipleBeneficiary(Beneficiary[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i++) {
            require(benefs[i].amount != 0, "Amount cannot be zero");
            _privateSale = _privateSale.sub(benefs[i].amount);
            _addBeneficiary(benefs[i].user, benefs[i].amount);
            emit AddPrivateSale(msg.sender, benefs[i].user, benefs[i].amount);
        }
    }

    // function deleteBeneficiary(address user) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     uint256 amount = _deleteBeneficiary(user);
    //     _privateSale += amount;
    //     emit DeletePrivateSale(msg.sender, user);
    // }

    function deleteMultipleBeneficiary(address[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i++) {
            uint256 amount = _deleteBeneficiary(benefs[i]);
            _privateSale = _privateSale.add(amount);
            emit DeletePrivateSale(msg.sender, benefs[i]);
        }
    }

    function claimPrivateSale() external {
        uint256 privateSale = _releaseClaimable(_msgSender());
        _balances[_msgSender()] = _balances[_msgSender()].add(privateSale);
    }
}
