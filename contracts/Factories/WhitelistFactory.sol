// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../ERC20/Whitelist.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => address) public projects;
    address immutable _masterContract;

    constructor() {
        _masterContract = address(new Whitelist());
    }

    function getCurrentCounter() external view returns (uint256) {
        return _counter.current();
    }

    function createProject(
        address tokenAddress,
        uint64 startTimestamp,
        uint64 durationSeconds,
        uint64 cliff
    ) external onlyOwner returns (address) {
        address project = Clones.clone(_masterContract);
        Whitelist(project).init(
            tokenAddress,
            startTimestamp,
            durationSeconds,
            cliff
        );
        projects[_counter.current()] = project;
        _counter.increment();
        return project;
    }

    function getProject(uint256 counterIdx) external view returns (address) {
        return projects[counterIdx];
    }
}
