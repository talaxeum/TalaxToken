// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice Error handling message for Modifier
 */
error Function__notAuthorized();

/**
 * @notice Error handling message for Main Function
 */
error MainFunction__insufficientBalance();
error MainFunction__amountOverBalance();
error MainFunction__beneficiaryExist();


struct WhitelistStruct {
    uint256 lockedAmount;
    uint256 amount;
    bool isPhase1Claimed;
    uint256 latestClaimDay;
}

struct Beneficiary {
    address user;
    uint256 amount;
}

contract Whitelist is ReentrancyGuard, Ownable  {
    uint256 public privateSaleUsers;

    uint256 public privateSaleAmount;
    uint256 internal constant _phase1 = 73395000 * 1e18;
    uint256 internal constant _phase2 = 3820562 * 1e18; // daily limit

    uint256 public startPrivateSale;

    // beneficiary of tokens after they are released
    mapping(address => WhitelistStruct) private _beneficiary;

    address public _token;

    constructor(address token) {
        privateSaleAmount = 5000000 * 1e18;
        _token = token;
    }

    function beneficiary(address user)
        external
        view
        returns (
            uint256,
            uint256,
            bool,
            uint256
        )
    {
        WhitelistStruct memory beneficiary_ = _beneficiary[user];
        return (
            beneficiary_.lockedAmount,
            beneficiary_.amount,
            beneficiary_.isPhase1Claimed,
            beneficiary_.latestClaimDay
        );
    }

    function initiateWhitelist() external onlyOwner {
        startPrivateSale = block.timestamp;
    }

    function hasWhitelist(address user)
        external
        view
        returns (
            uint256,
            uint256,
            bool,
            uint256
        )
    {
        WhitelistStruct memory beneficiary_ = _beneficiary[user];
        return (
            beneficiary_.lockedAmount,
            beneficiary_.amount,
            beneficiary_.isPhase1Claimed,
            beneficiary_.latestClaimDay
        );
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
            if (_beneficiary[user].isPhase1Claimed == false) {
                _beneficiary[user].isPhase1Claimed = true;
                _beneficiary[user].latestClaimDay = 15 * 30;
                claimable =
                    claimable +
                    ((_phase1 * _beneficiary[user].lockedAmount) /
                        privateSaleAmount);
            }
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration >= 16 * 30 && lockDuration < 28 * 30) {
            if (_beneficiary[user].isPhase1Claimed == false) {
                _beneficiary[user].isPhase1Claimed = true;
                claimable =
                    claimable +
                    ((_phase1 * _beneficiary[user].lockedAmount) /
                        privateSaleAmount);
            }

            uint256 sinceLatestClaim = lockDuration -
                _beneficiary[user].latestClaimDay;
            _beneficiary[user].latestClaimDay = lockDuration;
            claimable =
                sinceLatestClaim *
                (claimable +
                    ((_phase2 * _beneficiary[user].lockedAmount) /
                        privateSaleAmount));
        } else {
            return 0;
        }

        return claimable;
    }

    function addBeneficiary(address user, uint256 amount) external onlyOwner {
        if (_beneficiary[user].lockedAmount != 0) {
            revert MainFunction__beneficiaryExist();
        } else {
            if (amount > privateSaleAmount) {
                revert MainFunction__insufficientBalance();
            }

            if (amount > 0) {
                _beneficiary[user].lockedAmount = amount;
                _beneficiary[user].amount = amount;
                _beneficiary[user].isPhase1Claimed = false;
                _beneficiary[user].latestClaimDay = 1;

                privateSaleUsers += 1;
                privateSaleAmount -= amount;
            }
        }
    }

    function deleteBeneficiary(address user)
        external
        onlyOwner
        returns (uint256)
    {
        if (_beneficiary[user].amount > 0) {
            privateSaleUsers -= 1;
            privateSaleAmount += _beneficiary[user].amount;
            uint256 ex_amount = _beneficiary[user].amount;

            delete _beneficiary[user];
            return ex_amount;
        } else {
            return 0;
        }
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable()
        external
    {
        if (_beneficiary[msg.sender].amount > 0) {
            uint256 claimableLockedAmount = _calculateClaimableAmount(msg.sender);

            if (claimableLockedAmount > 0) {
                _beneficiary[msg.sender].amount =
                    _beneficiary[msg.sender].amount -
                    claimableLockedAmount;

                // _beneficiary[user].userAddress = user;

                SafeERC20.safeTransfer(
                    IERC20(_token),
                    msg.sender,
                    claimableLockedAmount
                );
            }
        }
    }
}
