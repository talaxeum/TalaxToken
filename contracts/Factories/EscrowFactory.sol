// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../ERC721/Escrow.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EscrowFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => address) public projects;
    address immutable _masterContract;

    constructor() {
        _masterContract = address(new ProjectEscrow());
    }

    function getCurrentCounter() external view returns (uint256) {
        return _counter.current();
    }

    function createProject(
        address tokenAddress,
        uint256 artistFee,
        uint256 projectFee,
        uint256 advisoryFee,
        uint256 platformFee
    ) external onlyOwner returns (address) {
        address project = Clones.clone(_masterContract);
        ProjectEscrow(project).init(
            tokenAddress,
            artistFee,
            projectFee,
            advisoryFee,
            platformFee
        );
        projects[_counter.current()] = project;
        _counter.increment();
        return project;
    }

    function getProject(uint256 counterIdx) external view returns (address) {
        return projects[counterIdx];
    }
}
