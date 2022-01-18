// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CertificateToken is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => address) public firstOwner;

    constructor() ERC721("Certificate", "CERT") {}

    function certificateMint(address holder, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();


        uint256 newCertId = _tokenIds.current();

        firstOwner[newCertId] = holder;
        _mint(holder, newCertId);
        _setTokenURI(newCertId, tokenURI);

        return newCertId;
    }
}