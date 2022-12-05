// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "../ERC20/Vesting.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => address) public vestingWallets;
    address immutable _masterContract;

    constructor() {
        _masterContract = address(new Vesting());
    }

    function getCurrentCounter() external view returns (uint256) {
        return _counter.current();
    }

    function createVesting(
        address token,
        address beneficiary,
        uint64 start,
        uint64 duration,
        uint64 cliff
    ) external onlyOwner returns (address) {
        address vesting = Clones.clone(_masterContract);
        Vesting(vesting).init(token, beneficiary, start, duration, cliff);
        vestingWallets[_counter.current()] = vesting;
        _counter.increment();
        return vesting;
    }

    function getVestingWallet(
        uint256 counterIdx
    ) external view returns (address) {
        return vestingWallets[counterIdx];
    }
}
