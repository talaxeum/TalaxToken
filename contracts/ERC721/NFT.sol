// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol"; // Royalties contract
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, ERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address public artist;
    uint256 public tokenPrice;
    uint96 public royaltyPercentage;
    address private token;

    constructor() ERC721("TokenName", "TKN") {}

    /**
     * @notice Using init function instead of constructor because the contract will be deployed using clone contract
     */
    function init(
        address _artist,
        address _token,
        uint96 _royaltyPercentage,
        uint256 _tokenPrice
    ) external {
        require(token == address(0), "Initiated");
        artist = _artist;
        token = _token;
        tokenPrice = _tokenPrice;
        _setDefaultRoyalty(_artist, _royaltyPercentage);
        transferOwnership(_artist);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /* ----------------- The following functions are overrides required by Solidity. ---------------- */

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
