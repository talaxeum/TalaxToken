// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/TokenTimelock.sol)

pragma solidity ^0.8.0;

import "./src/SafeMath.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */
contract MultiLockable {
	// ERC20 basic token contract being held
	mapping(address => uint256) private timeLockedWallet;
	uint256 private _totalAmount;
	uint256 private immutable _startLockedWallet;


	constructor(uint256 totalAmount_) {
		require(
			totalAmount_ > 0,
			"MultiTokenTimelock: total amount cannot be zero"
		);
		_totalAmount = totalAmount_;
		_startLockedWallet = block.timestamp;
	}

	/**
	 * @return the token being held.
	 */
	function amount() external view returns (uint256) {
		return timeLockedWallet[msg.sender];
	}

	function startLocked() external view returns (uint256) {
		return _startLockedWallet;
	}

	function addUser(address user_, uint256 amount_) external {
		require(user_ != address(0), "MultiTokenTimeLock: Cannot add address(0)");

		require(timeLockedWallet[user_] == 0, "MultiTokenTimeLock: User allredy exist");

		require(
			amount_ < _totalAmount,
			"MultiTokenTimeLock: Amount is larger than allocated Total Amount left"
		);

		timeLockedWallet[user_] = amount_;
		_totalAmount = SafeMath.sub(_totalAmount, amount_, "MultiTokenTimeLock: Cannot subs larget than total amount");
	}

	function deleteUser(address user_) external {
		require(
			timeLockedWallet[user_] == 0,
			"MultiTokenTimeLock: User has some token left in locked wallet"
		);

		_totalAmount = SafeMath.add(_totalAmount, timeLockedWallet[user_]);
		delete timeLockedWallet[user_];
	}

	function calculateClaimableAmount(address user_, uint24[43] memory rate_)
		private
		view
		returns (uint256)
	{
		uint256 lockedAmount = timeLockedWallet[user_];

		uint256 months = (block.timestamp - _startLockedWallet) / 30 days;
		uint256 claimable;

		for (uint256 i = 0; i <= months; i++) {
			claimable = SafeMath.add(
				claimable,
				SafeMath.mul(lockedAmount, ((rate_[i] * 10**18) / _totalAmount))
			);
		}

		require(claimable != 0, "MultiTokenTimeLock: There's nothing to claim yet");
		return claimable;
	}

	/**
	 * @notice Transfers tokens held by timelock to beneficiary.
	 */
	function releaseClaimable(uint24[43] memory rate_) external returns (uint256) {
		require(_totalAmount > 0, "MultiTokenTimeLock: no tokens left");

		uint256 claimableLockedAmount = calculateClaimableAmount(msg.sender, rate_);
		require(
			claimableLockedAmount > 0,
			"MultiTokenTimeLock: no tokens to release"
		);

		delete timeLockedWallet[msg.sender];
		_totalAmount = SafeMath.sub(
			_totalAmount,
			claimableLockedAmount,
			"MultiTokenTimeLock: Cannot substract total amount with claimable"
		);

		return claimableLockedAmount;
	}
}
