// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./SafeMath.sol";

contract Multilockable {
    using SafeMath for uint256;
    uint256 private totalUser;

    uint256 public constant totalAmount = 14679 * 1e3 * 1e18;
    uint256 public constant phase_1_total = 1467900 * 1e18;
    uint256 public constant phase_2_total = 36195 * 1e18;

    uint256 public _startPrivateSale;

    struct Multilock {
        uint256 lockedAmount;
        uint256 amount;
        bool phase_1_claimed;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => Multilock) private beneficiary;

    constructor() {
        startPrivateSale = block.timestamp;
    }

    /**
     * @dev modifier functions
     */

    function hasMultilockable() external view returns (Multilock memory) {
        require(
            beneficiary[msg.sender].amount != 0,
            "Multilockable: You don't have any balance for private sale"
        );
        return beneficiary[msg.sender];
    }

    /**
     *  @dev 		Main Functions
     *  @return 	Claimable amount from Locked Wallet
     */
    function _calculateClaimableAmount(address user)
        internal
        returns (uint256)
    {
        uint256 claimable;

        uint256 lockDuration = (block.timestamp - _startPrivateSale) / 1 days;

        //Phase 1 of locked wallet release - monthly
        if (lockDuration < 16 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_1_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
                beneficiary[user].phase_1_claimed = true;
            }
            beneficiary[user].latestClaimDay = 15 * 30;
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration + 1 > 16 * 30 && lockDuration < 28 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_1_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
                beneficiary[user].phase_1_claimed = true;
            }

            uint256 sinceLatestClaim = lockDuration -
                beneficiary[user].latestClaimDay;
            claimable =
                sinceLatestClaim *
                claimable.add(
                    SafeMath.div(
                        SafeMath.mul(
                            phase_2_total,
                            beneficiary[user].lockedAmount
                        ),
                        totalAmount
                    )
                );
            beneficiary[user].latestClaimDay = lockDuration;
        }

        require(claimable != 0, "Multilockable: There's nothing to claim yet");
        return claimable;
    }

    function _addBeneficiary(address[] calldata user_, uint256 amount_)
        internal
    {
        require(
            amount_ < totalAmount + 1,
            "Multilockable: not enough balance to add a new user"
        );

        for (uint256 i = 0; i < user_.length; i++) {
            require(
                beneficiary[user_[i]].amount > 0,
                "Multilockable: This user already registered"
            );
            beneficiary[user_[i]].lockedAmount = amount_;
            beneficiary[user_[i]].amount = amount_;
            beneficiary[user_[i]].phase_1_claimed = false;
            beneficiary[user_[i]].latestClaimDay = 1;

            totalUser += 1;
            totalAmount -= amount_;
        }
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function _releaseClaimable(address user_) internal returns (uint256) {
        require(beneficiary[user_].amount > 0, "Multilockable: no tokens left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(user_);

        require(
            claimableLockedAmount > 0,
            "Multilockable: no tokens to release"
        );

        beneficiary[user_].amount = SafeMath.sub(
            beneficiary[user_].amount,
            claimableLockedAmount,
            "Multilockable: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}
