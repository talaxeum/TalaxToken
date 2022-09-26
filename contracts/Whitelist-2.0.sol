// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

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
contract VestingWallet is Context {
    event ERC20Released(address indexed token, uint256 amount);

    // mapping(address => uint256) private _erc20Released;
    // address private immutable _beneficiary;
    mapping(address => mapping(address => uint256)) private _erc20Released;
    mapping(address => uint256) _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    // uint256 private lastMonth;
    mapping(address => uint256) private _lastMonth;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(uint64 startTimestamp, uint64 durationSeconds) payable {
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
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token][msg.sender];
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(block.timestamp)) - released(token);
    }

    /**
     * @dev Getter for the current running month of the vesting process
     */

    function _currentMonth() internal view returns (uint256) {
        return (uint64(block.timestamp) - start()) / 30 days;
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release(address token) public virtual {
        uint256 amount = releasable(token);
        if (_currentMonth() > _lastMonth[msg.sender]) {
            _lastMonth[msg.sender] = _currentMonth();
            _erc20Released[token][msg.sender] += amount;
            emit ERC20Released(token, amount);
            SafeERC20.safeTransfer(IERC20(token), msg.sender, amount);
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
    function vestedAmount(address token, uint64 timestamp)
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
            _vestingSchedule(
                _beneficiary[msg.sender] + released(token),
                timestamp
            );
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
