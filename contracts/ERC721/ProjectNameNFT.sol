// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./Escrow.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol"; // Royalties contract
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProjectNameNFT is ERC721URIStorage, ERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 tokenPrice;
    uint96 public royaltyPercentage;
    address private token;
    address private escrowAddress;

    // Change according to token Name and Symbol
    constructor() ERC721("NAME", "SYMBOL") {}

    function init(
        address _projectOwner,
        address _token,
        address _escrowAddress,
        uint96 _royaltyPercentage,
        uint256 _tokenPrice
    ) external {
        require(token == address(0), "Initiated");
        token = _token;
        escrowAddress = _escrowAddress;
        royaltyPercentage = _royaltyPercentage * 100;
        tokenPrice = _tokenPrice;
        transferOwnership(_projectOwner);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function burnNFT(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _mintNFT(
        address recipient,
        string memory tokenURI
    ) internal returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function mintNFTWithRoyalty(
        address recipient,
        string memory tokenURI,
        address royaltyReceiver
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _mintNFT(recipient, tokenURI);
        _setTokenRoyalty(tokenId, royaltyReceiver, royaltyPercentage);

        return tokenId;
    }

    function claimReward(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not eligible");
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        uint256 capstone = Escrow(escrowAddress).getCapstone(address(this));
        uint256 reward = (tokenPrice * contractBalance) / capstone;
        SafeERC20.safeTransfer(IERC20(token), msg.sender, reward);
    }

    // If all of the NFT in this project is priced the same
    function claimTotalReward() external {
        require(balanceOf(msg.sender) > 0, "Not eligible");
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        uint256 capstone = Escrow(escrowAddress).getCapstone(address(this));
        uint256 reward = (balanceOf(msg.sender) *
            tokenPrice *
            contractBalance) / capstone;
        SafeERC20.safeTransfer(IERC20(token), msg.sender, reward);
    }
}
