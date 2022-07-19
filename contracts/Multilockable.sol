// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Multilockable {
    using SafeMath for uint256;
    uint256 public privateSaleUsers;

    uint256 public privateSaleAmount;
    uint256 internal constant _phase1 = 73395000 * 1e18;
    uint256 internal constant _phase2 = 3820562 * 1e18; // daily limit

    uint256 public startPrivateSale;

    struct Multilock {
        uint256 lockedAmount;
        uint256 amount;
        bool phase_1_claimed;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => Multilock) private beneficiary;

    constructor() {
        privateSaleAmount = 1467900000 * 1e18;
    }

    function _initiatePrivateSale() internal {
        startPrivateSale = block.timestamp;
    }

    function hasMultilockable() external view returns (Multilock memory) {
        require(
            beneficiary[msg.sender].amount != 0,
            "PrivateSale: You don't have any balance for private sale"
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

        uint256 lockDuration = (block.timestamp - startPrivateSale) / 1 days;

        //Phase 1 of locked wallet release - monthly
        if (lockDuration < 16 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
                beneficiary[user].phase_1_claimed = true;
            }
            beneficiary[user].latestClaimDay = 15 * 30;
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration >= 16 * 30 && lockDuration < 28 * 30) {
            if (beneficiary[user].phase_1_claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, beneficiary[user].lockedAmount),
                        privateSaleAmount
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
                        SafeMath.mul(_phase2, beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
            beneficiary[user].latestClaimDay = lockDuration;
        }

        require(claimable != 0, "PrivateSale: There's nothing to claim yet");
        return claimable;
    }

    function _addBeneficiary(address user_, uint256 amount_) internal {
        require(
            amount_ <= privateSaleAmount,
            "PrivateSale: not enough balance to add a new user"
        );
        require(
            beneficiary[user_].amount == 0,
            "PrivateSale: This user already registered"
        );
        beneficiary[user_].lockedAmount = amount_;
        beneficiary[user_].amount = amount_;
        beneficiary[user_].phase_1_claimed = false;
        beneficiary[user_].latestClaimDay = 1;

        privateSaleUsers += 1;
        privateSaleAmount -= amount_;
    }

    function _deleteBeneficiary(address user_) internal returns (uint256) {
        require(
            beneficiary[user_].amount != 0,
            "PrivateSale: This user doesnt exist"
        );
        privateSaleUsers -= 1;
        privateSaleAmount += beneficiary[user_].amount;
        uint256 ex_amount = beneficiary[user_].amount;

        delete beneficiary[user_];
        return ex_amount;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function _releaseClaimable(address user_) internal returns (uint256) {
        require(beneficiary[user_].amount > 0, "PrivateSale: no tokens left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(user_);

        require(claimableLockedAmount > 0, "PrivateSale: no tokens to release");

        beneficiary[user_].amount = SafeMath.sub(
            beneficiary[user_].amount,
            claimableLockedAmount,
            "PrivateSale: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}
