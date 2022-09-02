// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

address constant public_sale_address = 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;

/* ------------------------------------ Interfaces Addresses ------------------------------------ */
address constant stake_address = 0xd9145CCE52D386f254917e481eB44e9943F39138;

address constant private_sale_address = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;

address constant marketing_address_1 = 0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3;
address constant marketing_address_2 = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
address constant marketing_address_3 = 0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005;
// Strategic Partner Addresses
address constant team_and_project_coordinator_address_1 = 0xddaAd340b0f1Ef65169Ae5E41A8b10776a75482d;
address constant team_and_project_coordinator_address_2 = 0x0fC5025C764cE34df352757e82f7B5c4Df39A836;
address constant team_and_project_coordinator_address_3 = 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c;

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
