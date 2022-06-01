// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
