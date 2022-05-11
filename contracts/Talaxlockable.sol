// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./IBEP20.sol";
import "./Lockable.sol";
import "./SafeMath.sol";

contract Talaxlockable {
    using SafeMath for uint256;

    address talaxAddress;
    IBEP20 talax;

    /**
     * Lockable Object
     */
    Lockable public privatePlacementLockedWallet;
    Lockable public devPoolLockedWallet_1;
    Lockable public devPoolLockedWallet_2;
    Lockable public devPoolLockedWallet_3;
    Lockable public strategicPartnerLockedWallet_1;
    Lockable public strategicPartnerLockedWallet_2;
    Lockable public strategicPartnerLockedWallet_3;
    Lockable public teamAndProjectCoordinatorLockedWallet_1;
    Lockable public teamAndProjectCoordinatorLockedWallet_2;
    Lockable public teamAndProjectCoordinatorLockedWallet_3;

    uint256[55] private privatePlacementReleaseAmount = [
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(43706, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        SafeMath.mul(524475, 1e18),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
    ];

    uint256[55] private devPoolReleaseAmount = [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(154175, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        SafeMath.mul(650961, 1e18),
        0,
        0,
        0,
        0
    ];

    uint256[55] private strategicPartnerReleaseAmount = [
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(21875, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        SafeMath.mul(87500, 1e18),
        0,
        0,
        0,
        0
    ];

    uint256[55] private teamAndProjectCoordinatorReleaseAmount = [
        SafeMath.mul(105000, 1e18),
        0,
        0,
        0,
        SafeMath.mul(315000, 1e18),
        0,
        0,
        0,
        SafeMath.mul(315000, 1e18),
        0,
        0,
        0,
        SafeMath.mul(315000, 1e18),
        0,
        0,
        0,
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        SafeMath.mul(262500, 1e18),
        0,
        0,
        0,
        0
    ];

    constructor() {
        // talaxAddress
        talax = IBEP20(talaxAddress);

        /**
         * Locked Wallet Initialization
         */
        // privatePlacementLockedWallet = new Lockable(
        //     6993 * 1e3 * 1e18,
        //     talax.private_placement_address()
        // );
        // devPoolLockedWallet_1 = new Lockable(
        //     24668 * 1e3 * 1e18,
        //     talax.dev_pool_address_1()
        // );
        // devPoolLockedWallet_2 = new Lockable(
        //     24668 * 1e3 * 1e18,
        //     talax.dev_pool_address_2()
        // );
        // devPoolLockedWallet_3 = new Lockable(
        //     24668 * 1e3 * 1e18,
        //     talax.dev_pool_address_3()
        // );
        // strategicPartnerLockedWallet_1 = new Lockable(
        //     3500 * 1e3 * 1e18,
        //     talax.strategic_partner_address_1()
        // );
        // strategicPartnerLockedWallet_2 = new Lockable(
        //     3500 * 1e3 * 1e18,
        //     talax.strategic_partner_address_2()
        // );
        // strategicPartnerLockedWallet_3 = new Lockable(
        //     3500 * 1e3 * 1e18,
        //     talax.strategic_partner_address_3()
        // );
        // teamAndProjectCoordinatorLockedWallet_1 = new Lockable(
        //     10500 * 1e3 * 1e18,
        //     talax.team_and_project_coordinator_address_1()
        // );
        // teamAndProjectCoordinatorLockedWallet_2 = new Lockable(
        //     10500 * 1e3 * 1e18,
        //     talax.team_and_project_coordinator_address_2()
        // );
        // teamAndProjectCoordinatorLockedWallet_3 = new Lockable(
        //     10500 * 1e3 * 1e18,
        //     talax.team_and_project_coordinator_address_3()
        // );
    }

    // /**
    //  * @dev LockedWallet: Team And Project Coordinator Locked Wallet
    //  */
    // function unlockPrivatePlacementWallet() external {
    //     require(
    //         msg.sender == privatePlacementLockedWallet.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );

    //     uint256 timeLockedAmount = privatePlacementLockedWallet
    //         .releaseClaimable(privatePlacementReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // /**
    //  * @dev LockedWallet: Dev Pool Locked Wallet
    //  */
    // function unlockDevPoolWallet_1() external {
    //     require(
    //         msg.sender == devPoolLockedWallet_1.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = devPoolLockedWallet_1.releaseClaimable(
    //         devPoolReleaseAmount
    //     );

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockDevPoolWallet_2() external {
    //     require(
    //         msg.sender == devPoolLockedWallet_2.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = devPoolLockedWallet_2.releaseClaimable(
    //         devPoolReleaseAmount
    //     );

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockDevPoolWallet_3() external {
    //     require(
    //         msg.sender == devPoolLockedWallet_3.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = devPoolLockedWallet_3.releaseClaimable(
    //         devPoolReleaseAmount
    //     );

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // /**
    //  * @dev LockedWallet: Team And Project Coordinator Locked Wallet
    //  */
    // function unlockStrategicPartnerWallet_1() external {
    //     require(
    //         msg.sender == strategicPartnerLockedWallet_1.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = strategicPartnerLockedWallet_1
    //         .releaseClaimable(strategicPartnerReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockStrategicPartnerWallet_2() external {
    //     require(
    //         msg.sender == strategicPartnerLockedWallet_2.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = strategicPartnerLockedWallet_2
    //         .releaseClaimable(strategicPartnerReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockStrategicPartnerWallet_3() external {
    //     require(
    //         msg.sender == strategicPartnerLockedWallet_3.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = strategicPartnerLockedWallet_3
    //         .releaseClaimable(strategicPartnerReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // /**
    //  * @dev LockedWallet: Team And Project Coordinator Locked Wallet
    //  */
    // function unlockTeamAndProjectCoordinatorWallet_1() external {
    //     require(
    //         msg.sender ==
    //             teamAndProjectCoordinatorLockedWallet_1.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
    //         .releaseClaimable(teamAndProjectCoordinatorReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockTeamAndProjectCoordinatorWallet_2() external {
    //     require(
    //         msg.sender ==
    //             teamAndProjectCoordinatorLockedWallet_2.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
    //         .releaseClaimable(teamAndProjectCoordinatorReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }

    // function unlockTeamAndProjectCoordinatorWallet_3() external {
    //     require(
    //         msg.sender ==
    //             teamAndProjectCoordinatorLockedWallet_3.beneficiary(),
    //         "TalaxToken: Wallet Owner Only"
    //     );
    //     uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
    //         .releaseClaimable(teamAndProjectCoordinatorReleaseAmount);

    //     talax.addBalance(msg.sender, timeLockedAmount);
    // }
}
