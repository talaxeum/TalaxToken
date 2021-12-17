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
contract Lockable {
	// ERC20 basic token contract being held
	uint256 private _amount;

	// beneficiary of tokens after they are released
	address private immutable _beneficiary;

	uint256 private _startLockedWallet;

	constructor(uint256 amount_, address beneficiary_) {
		require(amount_ > 0, "Amount must greater than zero");
		_amount = amount_;
		_beneficiary = beneficiary_;
		_startLockedWallet = block.timestamp;
	}

	/**
	 * @return the token being held.
	 */
	function amount() external view returns (uint256) {
		return _amount;
	}

	/**
	 * @return the beneficiary of the tokens.
	 */
	function beneficiary() external view returns (address) {
		return _beneficiary;
	}

	function calculateClaimableAmount(uint256[43] memory rate_)
		private
		view
		returns (uint256)
	{
		uint256 months = (block.timestamp - _startLockedWallet) / 30 days;
		uint256 claimable;

		for (uint256 i = 0; i <= months; i++) {
			claimable = SafeMath.add(
				claimable,
				SafeMath.mul(_amount, rate_[i])
			);
		}

		require(claimable != 0, "There's nothing to claim yet");
		return claimable;
	}

	/**
	 * @notice Transfers tokens held by timelock to beneficiary.
	 */
	function releaseClaimable(uint256[43] memory rate_)
		external
		returns (uint256)
	{
		require(_amount > 0, "TokenTimelock: no tokens left");

		uint256 claimableLockedAmount = calculateClaimableAmount(rate_);
		require(
			claimableLockedAmount > 0,
			"TokenTimelock: no tokens to release"
		);

		_amount = SafeMath.sub(
			_amount,
			claimableLockedAmount,
			"Cannot substract total amount with claimable"
		);

		return claimableLockedAmount;
	}
}
