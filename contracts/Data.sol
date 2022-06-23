// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Data {
    address public constant public_sale_address =
        0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
    address public constant private_placement_address =
        0x07A20dc6722563783e44BA8EDCA08c774621125E;
    address public constant dev_pool_address_1 =
        0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
    address public constant dev_pool_address_2 =
        0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
    address public constant dev_pool_address_3 =
        0x126974fa373267d86fAB6d6871Afe62ccB68e810;
    address public constant strategic_partner_address_1 =
        0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    address public constant strategic_partner_address_2 =
        0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    address public constant strategic_partner_address_3 =
        0xAeB26fB84d0E2b3B353Cd50f0A29FD40C916d2Ab;
    address public constant team_and_project_coordinator_address_1 =
        0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
    address public constant team_and_project_coordinator_address_2 =
        0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
    address public constant team_and_project_coordinator_address_3 =
        0x97620dEAdC98bC8173303686037ce7B986CF53C3;

    /**
     * @dev this is the release rate for partial token release
     */
    function privatePlacementReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
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
    }

    function devPoolReleaseAmount() internal pure returns (uint256[55] memory) {
        return [
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
    }

    function strategicPartnerReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
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
    }

    function teamAndProjectCoordinatorReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
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
    }
}
