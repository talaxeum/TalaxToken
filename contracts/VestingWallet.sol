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

    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private _token;
    address private _beneficiary;
    uint64 private _start;
    uint64 private _duration;
    uint64 private _cliff;

    uint256 private lastMonth;

    bool private _initStatus;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */

    function init(
        address token,
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds,
        uint64 cliff
    ) external {
        require(
            beneficiaryAddress != address(0),
            "VestingWallet: beneficiary is zero address"
        );

        require(_initStatus == false, "Initiated");
        _initStatus = true;
        _token = token;
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp + cliff;
        _duration = durationSeconds;
        _cliff = cliff;
    }

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

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
        return _erc20Released[_token];
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
        return (uint64(block.timestamp) - start()) / 30 days;
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release() public virtual {
        uint256 amount = releasable();
        if (_currentMonth() > lastMonth) {
            lastMonth = _currentMonth();
            _erc20Released[_token] += amount;
            emit ERC20Released(_token, amount);
            SafeERC20.safeTransfer(IERC20(_token), beneficiary(), amount);
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
        return
            _vestingSchedule(
                IERC20(_token).balanceOf(address(this)) + released(),
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
