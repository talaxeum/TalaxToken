// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../ERC721/NFT.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFactory is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => address) public collections;
    address immutable _masterContract;

    constructor() {
        _masterContract = address(new NFT());
    }

    function getCurrentCounter() external view returns (uint256) {
        return _counter.current();
    }

    function createCollection(
        address payable minter,
        address tokenAddress,
        address escrowAddress,
        uint96 royaltyPercentage,
        uint256 tokenPrice
    ) external onlyOwner returns (address) {
        address collection = Clones.clone(_masterContract);
        NFT(collection).init(
            minter,
            tokenAddress,
            escrowAddress,
            royaltyPercentage,
            tokenPrice
        );
        collections[_counter.current()] = collection;
        _counter.increment();
        return collection;
    }

    function getCollection(uint256 counterIdx) external view returns (address) {
        return collections[counterIdx];
    }
}
