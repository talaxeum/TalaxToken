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
		address user;
		uint256 amount;
		uint256 latestClaim;
		uint256 startLockedWallet;
	}
	// ERC20 basic token contract being held
	userLockedInfo[] internal userLockedWallets;
	mapping(address => uint256) private users;

	uint256 private _totalAmount;
	uint256 private _startLocked;

	constructor(uint256 totalAmount_) {
		require(
			totalAmount_ > 0,
			"MultiTokenTimelock: total amount cannot be zero"
		);
		_totalAmount = totalAmount_;
		_startLocked = block.timestamp;
	}

	/**
	 * @return the token being held.
	 */
	function _getIndex(address user_) external view returns(uint256){
		return getUserIndex(user_);
	}

	function _getAmount(address user_) external view returns (uint256) {
		return userLockedWallets[getUserIndex(user_)].amount;
	}

	function _getMonth(address user_) external view returns (uint256) {
		return userLockedWallets[getUserIndex(user_)].latestClaim;
	}

	function _getDuration(address user_) external view returns (uint256) {
		return
			(block.timestamp -
				userLockedWallets[getUserIndex(user_)].startLockedWallet) /
			30 days;
	}

	function getTestDuration() external view returns (uint256) {
		return (block.timestamp - _startLocked) / 30 days;
	}

	function getUserIndex(address user_) internal view returns (uint256) {
		return users[user_];
	}

	function _lockWallet(uint256 amount_, address user_) external {
		uint256 index = users[user_];
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot add address(0)"
		);

		require(
			amount_ < _totalAmount,
			"MultiTokenTimeLock: Amount is larger than allocated Total Amount left"
		);

		if (index == 0) {
			// This stakeholder stakes for the first time
			// We need to add him to the stakeHolders and also map it into the Index of the stakes
			// The index returned will be the index of the stakeholder in the stakeholders array
			if (userLockedWallets.length == 0){
				userLockedWallets.push();
				userLockedWallets.push();
			}else{
				userLockedWallets.push();
			}
			
			// Calculate the index of the last item in the array by Len-1
			uint256 userIndex = userLockedWallets.length - 1;
			// Assign the address to the new index
			userLockedWallets[userIndex].user = user_;
			userLockedWallets[userIndex].amount = amount_;
			userLockedWallets[userIndex].latestClaim = 0;
			userLockedWallets[userIndex].startLockedWallet = block.timestamp;
			// Add index to the stakeHolders
			users[user_] = userIndex;

			index = userIndex;
		}

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
			userLockedWallets[getUserIndex(user_)].amount
		);
		delete userLockedWallets[getUserIndex(user_)];
	}

	function calculateClaimableAmount(
		uint256[43] memory rate_,
		userLockedInfo memory current_info
	) internal view returns (uint256) {
		uint256 months = (block.timestamp - current_info.startLockedWallet) /
			30 days;
		uint256 claimable;

		for (uint256 i = current_info.latestClaim; i <= months; i++) {
			claimable = SafeMath.add(
				claimable,
				SafeMath.div(
					SafeMath.mul(current_info.amount, rate_[i]),
					1e16,
					"Cannot divide 0"
				)
			);
		}

		current_info.latestClaim = months + 1;

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

		require(getUserIndex(user_) != 0, "MultiTokenTimeLock: User doesn't exist");

		userLockedInfo memory current_info = userLockedWallets[
			getUserIndex(user_)
		];

		uint256 claimableLockedAmount = calculateClaimableAmount(
			rate_,
			current_info
		);
		require(
			claimableLockedAmount > 0,
			"MultiTokenTimeLock: no tokens to release"
		);

		current_info.amount = SafeMath.sub(
			current_info.amount,
			claimableLockedAmount,
			"MultiTokenTimeLock: Cannot do this operation"
		);

		if (current_info.amount == 0) {
			delete current_info;
		}

		_totalAmount = SafeMath.add(_totalAmount, claimableLockedAmount);

		return claimableLockedAmount;
	}
}
