// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "../Whitelist.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => address) public whitelists;
    address immutable _masterContract;

    constructor() {
        _masterContract = address(new Whitelist());
    }

    function getCurrentCounter() external view returns (uint256) {
        return _counter.current();
    }

    function createWhitelist(
        address token,
        uint64 start,
        uint64 duration,
        uint64 cliff
    ) external onlyOwner returns (address) {
        address whitelist = Clones.clone(_masterContract);
        Whitelist(whitelist).init(token, start, duration, cliff);
        whitelists[_counter.current()] = whitelist;
        _counter.increment();
        return whitelist;
    }

    function getWhitelist(uint256 counterIdx) external view returns (address) {
        return whitelists[counterIdx];
    }
}
