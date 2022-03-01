// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TalaxToken.sol";

contract TestLockable{
    function testInitialLockable() public {
        TalaxToken talax = TalaxToken(DeployedAddresses.TalaxToken());


    }
}