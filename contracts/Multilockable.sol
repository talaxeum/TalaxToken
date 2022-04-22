// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Multilockable {
    using SafeMath for uint256;
    address public owner;
    uint256 private totalUser;

    uint256 private phase_1_total;
    uint256 private phase_2_total;

    struct LockedWallet {
        uint256 amount;
        uint256 startLockedWallet;
        uint256 latestClaimMonth;
        uint256 latestClaimDay;
    }

    // beneficiary of tokens after they are released
    mapping(address => LockedWallet) private _beneficiary;

    constructor() {
        owner = msg.sender;
        phase_1_total = 1467900 * 1e18;
        phase_2_total = 36195 * 1e18;
    }

    /**
     * @dev modifier functions
     */

    modifier onlyTalax() {
        require(
            msg.sender == owner,
            "Multilockable: caller have to be TalaxToken Smart Contract"
        );
        _;
    }

    /**
     *  @dev 		Main Functions
     *  @return 	Claimable amount from Locked Wallet
     */
    function _calculateClaimableAmount(address user_)
        internal
        returns (uint256)
    {
        uint256 period = (block.timestamp -
            _beneficiary[user_].startLockedWallet) / 30 days;
        uint256 claimable;

        if (period < 16) {
            for (
                uint256 i = _beneficiary[user_].latestClaimMonth;
                i < period;
                i++
            ) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(phase_1_total, _beneficiary[user_].amount),
                        14679000
                    )
                );
            }

            _beneficiary[user_].latestClaimMonth = period + 1;
        }
        if (period >= 16 && period < 28) {
            uint256 daily = (block.timestamp -
                _beneficiary[user_].startLockedWallet) / 24 hours;

            for (uint256 j = _beneficiary[user_].latestClaimDay; j <= 30; j++) {
                claimable = claimable.add(
                    SafeMath.div(
                        SafeMath.mul(phase_2_total, _beneficiary[user_].amount),
                        14679000
                    )
                );
            }

            _beneficiary[user_].latestClaimDay = daily + 1;

            if (daily == 30) {
                _beneficiary[user_].latestClaimDay = 1;
                _beneficiary[user_].latestClaimMonth = period + 1;
            }
        }

        require(claimable != 0, "Multilockable: There's nothing to claim yet");
        return claimable;
    }

    function addBeneficiary(uint256 amount_, address user_) external onlyTalax {
        _beneficiary[user_].amount = amount_;
        _beneficiary[user_].startLockedWallet = block.timestamp;
        _beneficiary[user_].latestClaimDay = 1;

        totalUser += 1;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function releaseClaimable(address user_)
        external
        onlyTalax
        returns (uint256)
    {
        require(
            _beneficiary[user_].amount > 0,
            "Multilockable: no tokens left"
        );

        uint256 claimableLockedAmount = _calculateClaimableAmount(user_);

        require(
            claimableLockedAmount > 0,
            "Multilockable: no tokens to release"
        );

        _beneficiary[user_].amount = SafeMath.sub(
            _beneficiary[user_].amount,
            claimableLockedAmount,
            "Multilockable: Cannot substract total amount with claimable"
        );

        return claimableLockedAmount;
    }
}
