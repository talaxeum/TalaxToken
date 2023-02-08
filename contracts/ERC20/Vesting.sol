// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

contract Vesting is Context {
    event ERC20Released(address indexed token, uint256 amount);

    uint256 private _released;
    uint256 public start;
    uint256 public duration;
    uint256 private lastMonth;
    address constant token = address(0);
    address public beneficiary;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */

    constructor(
        address _user,
        uint256 _start,
        uint256 _duration,
        uint256 _cliff
    ) {
        beneficiary = _user;
        start = _start + _cliff;
        duration = _duration;
    }

    function releasable() public view virtual returns (uint256) {
        return vestedAmount(block.timestamp) - _released;
    }

    function _currentMonth() internal view returns (uint256) {
        return block.timestamp - start / 30 days;
    }

    function release() public virtual {
        uint256 amount = releasable();
        if (_currentMonth() > lastMonth) {
            lastMonth = _currentMonth();
            _released += amount;
            IERC20(token).transfer(beneficiary, amount);
            emit ERC20Released(token, amount);
        }
    }

    function vestedAmount(
        uint256 timestamp
    ) public view virtual returns (uint256) {
        return
            _vestingSchedule(
                IERC20(token).balanceOf(address(this)) + _released,
                timestamp
            );
    }

    function _vestingSchedule(
        uint256 totalAllocation,
        uint256 timestamp
    ) internal view virtual returns (uint256) {
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}
