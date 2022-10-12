// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

address constant public_sale_address = 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;

address payable constant team_and_project_coordinator_address_1 = payable(
    0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F
);
address payable constant team_and_project_coordinator_address_2 = payable(
    0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a
);
address payable constant team_and_project_coordinator_address_3 = payable(
    0x97620dEAdC98bC8173303686037ce7B986CF53C3
);

address constant marketing_address_1 = 0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
address constant marketing_address_2 = 0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
address constant marketing_address_3 = 0x126974fa373267d86fAB6d6871Afe62ccB68e810;

address constant cex_listing_address = 0x0000000000000000000000000000000000000001;
address constant staking_reward = 0x0000000000000000000000000000000000000002;
address constant liquidity_reserve = 0x0000000000000000000000000000000000000003;
address constant dao_pool = 0x0000000000000000000000000000000000000004;

/* ------------------------------------ Interfaces Addresses ------------------------------------ */
// ? IStakable.sol
// address constant stake_address = 0xd9145CCE52D386f254917e481eB44e9943F39138;
address constant stake_address = 0xd9145CCE52D386f254917e481eB44e9943F39138;

// ? IWhitelist.sol
address constant private_placement_address = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;
// address constant private_sale_address = address(0);
// address constant strategic_partner = address(0);