// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

address constant public_sale_address = 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;

/* ------------------------------------ Interfaces Addresses ------------------------------------ */
address constant stake_address = address(0);

address constant private_sale_address = address(0);

address constant marketing_address_1 = 0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
address constant marketing_address_2 = 0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
address constant marketing_address_3 = 0x126974fa373267d86fAB6d6871Afe62ccB68e810;
// Strategic Partner Addresses
address constant team_and_project_coordinator_address_1 = 0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
address constant team_and_project_coordinator_address_2 = 0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
address constant team_and_project_coordinator_address_3 = 0x97620dEAdC98bC8173303686037ce7B986CF53C3;

struct Vesting {
    uint cliff;
    uint period;
    uint256 amount;
}

/**
 * @dev this is the release rate for partial token release
 */
function privatePlacementReleaseAmount() pure returns (uint256[51] memory) {
    return [
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(4370625, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
        SafeMath.mul(52447500, 1e18),
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

function strategicPartnerReleaseAmount() pure returns (uint256[51] memory) {
    return [
        SafeMath.mul(13125000, 1e18),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SafeMath.mul(13125000, 1e18),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18)
    ];
}

function teamAndProjectCoordinatorReleaseAmount()
    pure
    returns (uint256[51] memory)
{
    return [
        SafeMath.mul(21000000, 1e18),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SafeMath.mul(21000000, 1e18),
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18),
        SafeMath.mul(57166667, 1e18)
    ];
}

function marketingReleaseAmount() pure returns (uint256[51] memory) {
    return [
        SafeMath.mul(26250000, 1e18),
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
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18),
        SafeMath.mul(28437500, 1e18)
    ];
}
