// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Interfaces.sol";

contract Whitelist {
    using SafeMath for uint256;
    uint256 public privateSaleUsers;

    uint256 public privateSaleAmount;
    uint256 internal constant _phase1 = 73395000 * 1e18;
    uint256 internal constant _phase2 = 3820562 * 1e18; // daily limit

    uint256 public startPrivateSale;

    // beneficiary of tokens after they are released
    mapping(address => WhitelistStruct) private _beneficiary;

    /**
     * @notice Error handling message for Modifier
     */
    error Function__notAuthorized();

    /**
     * @notice Error handling message for Main Function
     */
    error MainFunction__insufficientBalance();

    address public _talax;
    address public _owner;

    constructor() {
        privateSaleAmount = 1467900000 * 1e18;
        _talax = msg.sender;
        _owner = msg.sender;
    }

    /* ------------------------------------------ modifier ------------------------------------------ */
    function _onlyTalax() internal view {
        // require(msg.sender == _talax, "Not authorized");
        if (msg.sender != _talax) {
            revert Function__notAuthorized();
        }
    }

    modifier onlyTalax() {
        _onlyTalax();
        _;
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    function changeTalaxAddress(address talax) external onlyTalax {
        _talax = talax;
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

    function initiateWhitelist() external onlyTalax {
        startPrivateSale = block.timestamp;
    }

    function hasWhitelist(address user)
        external
        view
        returns (WhitelistStruct memory)
    {
        return _beneficiary[user];
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
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, _beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
                _beneficiary[user].isPhase1Claimed = true;
                _beneficiary[user].latestClaimDay = 15 * 30;
            }
        }
        //Phase 2 of locked wallet release - daily
        else if (lockDuration >= 16 * 30 && lockDuration < 28 * 30) {
            if (_beneficiary[user].isPhase1Claimed == false) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase1, _beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
                _beneficiary[user].isPhase1Claimed = true;
            }

            uint256 sinceLatestClaim = lockDuration -
                _beneficiary[user].latestClaimDay;
            claimable =
                sinceLatestClaim *
                claimable.add(
                    SafeMath.div(
                        SafeMath.mul(_phase2, _beneficiary[user].lockedAmount),
                        privateSaleAmount
                    )
                );
            _beneficiary[user].latestClaimDay = lockDuration;
        } else {
            return 0;
        }

        return claimable;
    }

    function addBeneficiary(address user, uint256 amount) external onlyTalax {
        // require(amount <= privateSaleAmount, "Insufficient Total Balance");
        if (amount > privateSaleAmount) {
            revert MainFunction__insufficientBalance();
        }

        if (_beneficiary[user].amount > 0) {
            _beneficiary[user].lockedAmount = amount;
            _beneficiary[user].amount = amount;
            _beneficiary[user].isPhase1Claimed = false;
            _beneficiary[user].latestClaimDay = 1;

            privateSaleUsers += 1;
            privateSaleAmount -= amount;
        }
    }

    function deleteBeneficiary(address user)
        external
        onlyTalax
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
    function releaseClaimable(address user)
        external
        onlyTalax
        returns (uint256)
    {
        if (_beneficiary[user].amount > 0) {
            uint256 claimableLockedAmount = _calculateClaimableAmount(user);

            if (claimableLockedAmount > 0) {
                _beneficiary[user].amount = SafeMath.sub(
                    _beneficiary[user].amount,
                    claimableLockedAmount
                );

                return claimableLockedAmount;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
}
