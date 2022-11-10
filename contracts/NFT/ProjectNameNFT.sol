// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./ProjectNameEscrow.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol"; // Royalties contract
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ProjectNameNFT is ERC721URIStorage, ERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /**
     * @dev tokenPrices is mapping to keep track of each NFT prices, tokenId => tokenPrice
     */
    mapping(uint256 => uint256) private tokenPrices;
    uint96 public royaltyPercentage;
    address private token;
    address private escrowAddress;

    // Change according to token Name and Symbol
    constructor() ERC721("NAME", "SYMBOL") {}

    function init(
        address _minter,
        address _token,
        address _escrowAddress,
        uint96 _royaltyPercentage
    ) external {
        require(token == address(0), "Initiated");
        token = _token;
        escrowAddress = _escrowAddress;
        royaltyPercentage = _royaltyPercentage * 100;
        transferOwnership(_minter);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        require(tokenId != 0, "Invalid Id");
        return tokenPrices[tokenId];
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function burnNFT(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _mintNFT(address recipient, string memory tokenURI)
        internal
        returns (uint256)
    {
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
        require(ownerOf(tokenId) == msg.sender, "Not eligible to claim reward");
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        uint256 capstone = ProjectNameEscrow(escrowAddress).finalCap();
        uint256 reward = (tokenPrices[tokenId] * contractBalance) / capstone;
        SafeERC20.safeTransfer(IERC20(token), msg.sender, reward);
    }
}
