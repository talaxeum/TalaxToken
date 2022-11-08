// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Whitelist {
    using SafeMath for uint256;
    uint256 public users;

    uint256 public amount;
    uint256 internal constant _phase1 = 73395000 * 1e18;
    uint256 internal constant _phase2 = 3820562 * 1e18; // daily limit

    uint256 public start;

    address internal _owner;

    struct UserList {
        uint256 lockedAmount;
        uint256 amount;
        bool isPhase1Claimed;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => UserList) private beneficiary;

    constructor() {
        amount = 1467900000 * 1e18;
        _owner = msg.sender;
    }

    /**
     * @dev modifier functions
     */

    function _onlyTalax() internal view {
        require(msg.sender == _owner, "Not _owner");
    }

    modifier onlyTalax() {
        _onlyTalax();
        _;
    }

    function initiateWhitelist() external onlyTalax {
        start = block.timestamp;
    }

    function hasUserListable() external view returns (UserList memory) {
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

        uint256 lockDuration = (block.timestamp - start) / 1 days;

        //Phase 1 of locked wallet release - monthly
        if (lockDuration < 16 * 30) {
            if (beneficiary[user].isPhase1Claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, beneficiary[user].lockedAmount),
                        amount
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
                        amount
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
                        amount
                    )
                );
            beneficiary[user].latestClaimDay = lockDuration;
        }

        require(claimable != 0, "Nothing to claim yet");
        return claimable;
    }

    function addBeneficiary(address user_, uint256 amount_) external onlyTalax {
        require(amount_ <= amount, "Insufficient Total Balance");
        require(beneficiary[user_].amount == 0, "Cannot add Registered User");

        beneficiary[user_].lockedAmount = amount_;
        beneficiary[user_].amount = amount_;
        beneficiary[user_].isPhase1Claimed = false;
        beneficiary[user_].latestClaimDay = 1;

        users += 1;
        amount -= amount_;
    }

    function deleteBeneficiary(address user_)
        external
        onlyTalax
        returns (uint256)
    {
        require(beneficiary[user_].amount != 0, "User not Registered");
        users -= 1;
        amount += beneficiary[user_].amount;
        uint256 ex_amount = beneficiary[user_].amount;

        delete beneficiary[user_];
        return ex_amount;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable(address user_)
        external
        onlyTalax
        returns (uint256)
    {
        require(beneficiary[user_].amount > 0, "No Tokens Left");

        uint256 claimableLockedAmount = _calculateClaimableAmount(user_);

        require(claimableLockedAmount > 0, "No Tokens to Release for Now");

        beneficiary[user_].amount = SafeMath.sub(
            beneficiary[user_].amount,
            claimableLockedAmount
        );

        return claimableLockedAmount;
    }
}
