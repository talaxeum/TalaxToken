// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract WhitelistVesting is Context, Ownable {
    event ERC20Released(
        address indexed token,
        address indexed user,
        uint256 amount
    );

    struct Beneficiary {
        address user;
        uint256 amount;
    }

    // mapping(address => uint256) private _erc20Released;
    // address private immutable _beneficiary;
    address private _token;
    mapping(address => mapping(address => uint256)) private _erc20Released;
    mapping(address => uint256) _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    // uint256 private lastMonth;
    mapping(address => uint256) private _lastMonth;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(
        address token,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) payable {
        _token = token;
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _start;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
     * @dev Amount of token already released
     */
    function released() public view virtual returns (uint256) {
        return _erc20Released[_token][msg.sender];
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable() public view virtual returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released();
    }

    /**
     * @dev Getter for the current running month of the vesting process
     */

    function _currentMonth() internal view returns (uint256) {
        return (uint64(block.timestamp) - start()) / 1 minutes;
    }

    function _unsafeInc(uint256 x) internal pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    /**
     * @dev Vest token for a user
     *
     */
    function _vest(address user, uint256 amount) internal {
        _beneficiary[user] += amount;
    }

    /**
     * @dev delete Vest token for a user
     *
     */
    function _delete(address user) internal {
        delete _beneficiary[user];
    }

    function addMultiVesting(Beneficiary[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i = _unsafeInc(i)) {
            _vest(users[i].user, users[i].amount);
        }
    }

    function deleteMultiVesting(Beneficiary[] calldata users)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i = _unsafeInc(i)) {
            _delete(users[i].user);
        }
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release() public virtual {
        uint256 amount = releasable();
        if (_currentMonth() > _lastMonth[msg.sender]) {
            _lastMonth[msg.sender] = _currentMonth();
            _beneficiary[msg.sender] -= amount;
            _erc20Released[_token][msg.sender] += amount;
            emit ERC20Released(_token, msg.sender, amount);
            SafeERC20.safeTransfer(IERC20(_token), msg.sender, amount);
        }
    }

    // ? Default function
    // function release(address token) public virtual {
    //     uint256 amount = releasable(token);
    //     _erc20Released[token] += amount;
    //     emit ERC20Released(token, amount);
    //     SafeERC20.safeTransfer(IERC20(token), beneficiary(), amount);
    // }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(uint64 timestamp)
        public
        view
        virtual
        returns (uint256)
    {
        // return
        //     _vestingSchedule(
        //         IERC20(token).balanceOf(address(this)) + released(token),
        //         timestamp
        //     );
        return
            _vestingSchedule(_beneficiary[msg.sender] + released(), timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp)
        internal
        view
        virtual
        returns (uint256)
    {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}
