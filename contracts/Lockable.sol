// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Lockable {
    uint256 private _amount;

    address private owner;
    // beneficiary of tokens after they are released
    address public immutable beneficiary;

    uint256 private _startLockedWallet;

    uint256 private _latestClaimMonth;

    constructor(uint256 amount_, address beneficiary_) {
        _amount = amount_;
        beneficiary = beneficiary_;
        _startLockedWallet = block.timestamp;
        owner = msg.sender;
    }

    /**
     * @dev modifier functions
     */

    function _onlyTalax() internal view{
        require(msg.sender == owner, "Not owner");
    }

    modifier onlyTalax() {
        _onlyTalax();
        _;
    }

    /**
     * @notice Initiate Locked Wallet
     */

    function initiateLockedWallet() external onlyTalax {
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

        require(claimable != 0, "Nothing to claim yet");
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
