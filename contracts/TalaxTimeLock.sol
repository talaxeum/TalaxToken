// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract Talaxtimelock is TimelockController {

    /**
     * This contract is example of what we are using on openzeppelin app
     */
     
    address[] proposer = [0xf966eE21c62CBAf23e2e800CFc568FD9A216F9c9];
    address[] executor = [0xf966eE21c62CBAf23e2e800CFc568FD9A216F9c9];

    constructor()
        TimelockController(
            3,
            proposer,
            executor
        )
    {}
}
