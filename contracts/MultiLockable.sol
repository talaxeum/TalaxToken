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
	struct userLockedInfo {
		uint256 amount;
		uint256 latestClaim;
		uint256 startLockedWallet;
	}
	// ERC20 basic token contract being held
	mapping(address => userLockedInfo) private timeLockedWallet;
	uint256 private _totalAmount;

	constructor(uint256 totalAmount_) {
		require(
			totalAmount_ > 0,
			"MultiTokenTimelock: total amount cannot be zero"
		);
		_totalAmount = totalAmount_;
	}

	function _hasLockedAmount(address user_) external view returns (uint256) {
		return timeLockedWallet[user_].amount;
	}

	function _hasLockedMonth(address user_) external view returns (uint256) {
		return timeLockedWallet[user_].latestClaim;
	}

	/**
	 * @return the token being held.
	 */
	function amount() external view returns (uint256) {
		return timeLockedWallet[msg.sender].amount;
	}

	function startLocked() external view returns (uint256) {
		return timeLockedWallet[msg.sender].startLockedWallet;
	}

	function addUser(address user_, uint256 amount_) external {
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot add address(0)"
		);

		require(
			timeLockedWallet[user_].amount == 0,
			"MultiTokenTimeLock: User allredy exist"
		);

		require(
			amount_ < _totalAmount,
			"MultiTokenTimeLock: Amount is larger than allocated Total Amount left"
		);

		timeLockedWallet[user_].amount = amount_;
		timeLockedWallet[user_].latestClaim = 0;
		timeLockedWallet[user_].startLockedWallet = block.timestamp;
		_totalAmount = SafeMath.sub(
			_totalAmount,
			amount_,
			"MultiTokenTimeLock: Cannot subs larget than total amount"
		);
	}

	function deleteUser(address user_) external {
		require(
			user_ != address(0),
			"MultiTokenTimeLock: User has some token left in locked wallet"
		);

		_totalAmount = SafeMath.add(
			_totalAmount,
			timeLockedWallet[user_].amount
		);
		delete timeLockedWallet[user_];
	}

	function calculateClaimableAmount(address user_, uint256[43] memory rate_)
		private
		returns (uint256)
	{
		uint256 months = (block.timestamp -
			timeLockedWallet[user_].startLockedWallet) / 30 days;
		uint256 claimable;

		for (
			uint256 i = timeLockedWallet[user_].latestClaim;
			i <= months;
			i++
		) {
			claimable = SafeMath.add(
				claimable,
				SafeMath.div(
					SafeMath.mul(timeLockedWallet[user_].amount, rate_[i]),
					1e16,
					"Cannot divide 0"
				)
			);
		}
		timeLockedWallet[user_].latestClaim = months + 1;

		require(
			claimable != 0,
			"MultiTokenTimeLock: There's nothing to claim yet"
		);
		return claimable;
	}

	/**
	 * @notice Transfers tokens held by timelock to beneficiary.
	 */
	function releaseClaimable(uint256[43] memory rate_, address user_)
		external
		returns (uint256)
	{
		require(_totalAmount > 0, "MultiTokenTimeLock: no tokens left");

		uint256 claimableLockedAmount = calculateClaimableAmount(
			user_,
			rate_
		);
		require(
			claimableLockedAmount > 0,
			"MultiTokenTimeLock: no tokens to release"
		);

		timeLockedWallet[user_].amount = SafeMath.sub(
			timeLockedWallet[user_].amount,
			claimableLockedAmount,
			"MultiTokenTimeLock: Cannot do this operation"
		);

		if (timeLockedWallet[user_].amount == 0) {
			delete timeLockedWallet[user_];
		}

		_totalAmount = SafeMath.add(_totalAmount, claimableLockedAmount);

		return claimableLockedAmount;
	}
}
