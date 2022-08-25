// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WhiteList {
    using SafeMath for uint256;
    uint256 public privateSaleUsers;

    uint256 public privateSaleAmount;
    uint256 internal constant _phase1 = 73395000 * 1e18;
    uint256 internal constant _phase2 = 3820562 * 1e18; // daily limit

    uint256 public startPrivateSale;

    struct Multilock {
        uint256 lockedAmount;
        uint256 amount;
        bool isPhase1Claimed;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => Multilock) public beneficiary;

    address talaxAddress;

    constructor() {
        privateSaleAmount = 1467900000 * 1e18;
        talaxAddress = msg.sender;
    }

    /* ------------------------------------------ modifier ------------------------------------------ */
    function _onlyTalax() internal pure {
        require(msg.sender == talaxAddress, "Not authorized");
    }

    modifier onlyTalax() {
        _onlyTalax();
        _;
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    function initiateWhiteList() external onlyTalax {
        startPrivateSale = block.timestamp;
    }

    function hasMultilockable(address user)
        external
        view
        returns (Multilock memory)
    {
        return beneficiary[user];
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
            if (beneficiary[user].isPhase1Claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
                beneficiary[user].isPhase1Claimed = true;
            }
            beneficiary[user].latestClaimDay = 15 * 30;
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration >= 16 * 30 && lockDuration < 28 * 30) {
            if (beneficiary[user].isPhase1Claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
                beneficiary[user].isPhase1Claimed = true;
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

        require(claimable != 0, "Nothing to claim yet");
        return claimable;
    }

    function addBeneficiary(address user, uint256 amount) external onlyTalax {
        require(amount <= privateSaleAmount, "Insufficient Total Balance");
        require(beneficiary[user].amount == 0, "Cannot add Registered User");

        beneficiary[user].lockedAmount = amount;
        beneficiary[user].amount = amount;
        beneficiary[user].isPhase1Claimed = false;
        beneficiary[user].latestClaimDay = 1;

        privateSaleUsers += 1;
        privateSaleAmount -= amount;
    }

    function deleteBeneficiary(address user)
        external
        onlyTalax
        returns (uint256)
    {
        require(beneficiary[user].amount != 0, "User not Registered");
        privateSaleUsers -= 1;
        privateSaleAmount += beneficiary[user].amount;
        uint256 ex_amount = beneficiary[user].amount;

        delete beneficiary[user];
        return ex_amount;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable(address user)
        external
        onlyTalax
        returns (uint256)
    {
        require(beneficiary[user].amount > 0, "No Tokens Left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(user);

        require(claimableLockedAmount > 0, "No Tokens to Release for Now");

        beneficiary[user].amount = SafeMath.sub(
            beneficiary[user].amount,
            claimableLockedAmount
        );

        return claimableLockedAmount;
    }
}
