// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol"; // Royalties contract
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, ERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public artist;
    uint256 tokenPrice;
    uint96 public royaltyPercentage;
    address private token;
    address private escrowAddress;

    // TODO: confirm if the contract deployed by artist or talax admin
    constructor() ERC721("MyToken", "MTK") {}

    function init(
        address _artist,
        address _token,
        address _escrowAddress,
        uint96 _royaltyPercentage,
        uint256 _tokenPrice
    ) external {
        require(token == address(0), "Initiated");
        artist = _artist;
        token = _token;
        escrowAddress = _escrowAddress;
        royaltyPercentage = _royaltyPercentage * 100;
        tokenPrice = _tokenPrice;
        transferOwnership(_artist);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

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

    function _mintNFT(
        address recipient,
        string memory _tokenURI
    ) internal returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, _tokenURI);

        return newItemId;
    }

    function mintNFTWithRoyalty(
        address recipient,
        string memory _tokenURI
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _mintNFT(recipient, _tokenURI);
        _setTokenRoyalty(tokenId, artist, royaltyPercentage);
        return tokenId;
    }
}
