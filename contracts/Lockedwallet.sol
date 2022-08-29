// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Interfaces.sol";

contract LockedWallet is ILockable {
    uint256 internal _amount;

    address internal _owner;
    // beneficiary of tokens after they are released
    address public immutable beneficiary;

    uint256 public startLockedWallet;

    uint256 internal _latestClaimMonth;

    constructor(uint256 amount_, address beneficiary_) {
        _amount = amount_;
        beneficiary = beneficiary_;
        _owner = msg.sender;
    }

    /* ------------------------------------------ Modifier ------------------------------------------ */

    function _onlyTalax() internal view {
        require(msg.sender == _owner, "Not _owner");
    }

    modifier onlyTalax() {
        _onlyTalax();
        _;
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    function changeTalaxAddress(address talax) external onlyTalax {
        talaxAddress = talax;
    }

    /**
     * @notice Initiate Locked Wallet
     */

    function initiateLockedWallet() external override onlyTalax {
        startLockedWallet = block.timestamp;
    }

    function _unsafeInc(uint256 x) internal pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    /**
     *  @dev 		Main Functions
     *  @return 	Claimable amount from Locked Wallet
     */
    function _calculateClaimableAmount(uint256[51] memory amount_)
        internal
        returns (uint256)
    {
        uint256 months = (block.timestamp - startLockedWallet) / 30 days;
        uint256 claimable;

        for (uint256 i = _latestClaimMonth; i <= months; i = _unsafeInc(i)) {
            if (_latestClaimMonth <= 51) {
                claimable += amount_[i];
            }
        }

        _latestClaimMonth = months + 1;

        require(claimable != 0, "Nothing to claim yet");
        return claimable;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable(uint256[51] memory amount)
        external
        override
        onlyTalax
        returns (uint256)
    {
        uint256 claimableLockedAmount = _calculateClaimableAmount(amount);

        // require(claimableLockedAmount > 0, "Lockable: no tokens to release");

        _amount = SafeMath.sub(
            _amount,
            claimableLockedAmount,
            "Lockedwallet: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}
