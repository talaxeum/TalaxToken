// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 *
 * Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the `Escrow` rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its owner, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */

interface NFT {
    function tokenPrice() external returns (uint256);

    function artist() external returns (address);

    function safeMint(address to, string memory uri) external;
}

interface Token {
    function advisory() external returns (address);

    function platform() external returns (address);
}

error ProjectFailed();
error ProjectSuccessfullyFunded();

error ProjectHasEnded();
error ProjectStillFunding();

error NFTTaken();
error NFTPending();
error InvalidProof();
error NotOwner();
error DurationHasBeenChanged();

contract ProjectEscrow is Ownable {
    using Address for address payable;

    event DurationChanged(
        address project,
        uint256 oldDeadline,
        uint256 newDealine
    );
    event Deposit(
        address indexed payee,
        uint256 projectId,
        address nftContract,
        string tokenUri,
        uint256 price
    );
    event NftMinted(
        address indexed minter,
        uint256 projectId,
        address nftContract,
        string tokenUri
    );
    event Withdraw(
        address indexed withdrawer,
        uint256 projectId,
        uint256 amount
    );
    event CapstoneReached(address indexed project, uint256 status);
    event FundClaimed(address indexed claimer, address project, uint256 amount);

    // Capstones
    uint256 private softCap;
    uint256 private mediumCap;
    uint256 private hardCap;
    uint256 private finalCap;
    // Token Distribution Addresses
    uint256 private artistFee;
    uint256 private projectFee;
    uint256 private advisoryFee;
    uint256 private platformFee;

    uint256 private status;
    uint256 private deadline;
    uint256 private totalDeposit;

    bytes32 public nftRoot;
    bytes32 public depositRoot;
    address public token;
    bool private durationChanged;

    constructor(
        address _token,
        uint256 _artistFee,
        uint256 _projectFee,
        uint256 _advisoryFee,
        uint256 _platformFee
    ) {
        token = _token;
        artistFee = _artistFee;
        projectFee = _projectFee;
        advisoryFee = _advisoryFee;
        platformFee = _platformFee;
    }

    function updateProjectRoot(
        bytes32 _nftRoot,
        bytes32 _depositRoot
    ) public onlyOwner {
        nftRoot = _nftRoot;
        depositRoot = _depositRoot;
    }

    function changeDuration(uint256 _additionalTime) external onlyOwner {
        if (durationChanged) revert DurationHasBeenChanged();
        if (deadline <= block.timestamp) {
            revert ProjectHasEnded();
        }
        uint256 old = deadline;
        durationChanged = true;
        deadline += _additionalTime;
        emit DurationChanged(address(this), old, deadline);
    }

    function deposit(
        uint256 _projectId,
        address _nftContract,
        address _depositor,
        string memory _tokenUri,
        uint8 _status
    ) public payable virtual onlyOwner {
        if (deadline <= block.timestamp) revert ProjectHasEnded();
        if (status == 3) revert ProjectSuccessfullyFunded();

        uint256 _tokenPrice = NFT(_nftContract).tokenPrice();

        // Deposit for the current status
        // _userDeposits[msg.sender] += _tokenPrice;
        totalDeposit += _tokenPrice;
        // Track selected NFT
        // _preservedNft[_status][nftContract][tokenId] = msg.sender;

        IERC20(token).transferFrom(msg.sender, address(this), _tokenPrice);

        if (status < _status) {
            status = _status;
            finalCap = totalDeposit;
            emit CapstoneReached(address(this), status);
        }

        emit Deposit(
            _depositor,
            _projectId,
            _nftContract,
            _tokenUri,
            _tokenPrice
        );
    }

    // TODO: Create functions to mint NFT
    function mintNft(
        bytes32[] memory _proof,
        uint256 _projectId,
        address _nftContract,
        string memory _tokenUri
    ) public payable isRunning {
        // Merkle Proof to check user has already been picked this NFT
        bytes32 leaf = _generateLeaf(
            abi.encode(_projectId, _nftContract, _tokenUri, msg.sender)
        );
        if (!MerkleProof.verify(_proof, nftRoot, leaf)) {
            revert InvalidProof();
        }

        // Distribute Talax
        _distribute(
            artistFee,
            advisoryFee,
            platformFee,
            _nftContract,
            NFT(_nftContract).tokenPrice()
        );

        NFT(_nftContract).safeMint(msg.sender, _tokenUri);

        emit NftMinted(msg.sender, _projectId, _nftContract, _tokenUri);
    }

    function withdraw(
        bytes32[] memory _proof,
        uint256 _amount
    ) public virtual isRunning {
        // Merkle Proof to check user is a depositor
        bytes32 leaf = _generateLeaf(abi.encode(address(this), msg.sender));
        if (!MerkleProof.verify(_proof, depositRoot, leaf)) {
            revert InvalidProof();
        }

        IERC20(token).transfer(msg.sender, _amount);
    }

    function claimFunding() public onlyOwner isRunning {
        if (msg.sender != owner()) revert NotOwner();
        if (status == 0) revert ProjectFailed();

        uint256 amount = _count(finalCap, projectFee);

        IERC20(token).transfer(msg.sender, amount);

        emit FundClaimed(msg.sender, address(this), amount);
    }

    /* ------------------------------------------- Helpers ------------------------------------------ */

    modifier isRunning() {
        _isRunning();
        _;
    }

    function _isRunning() internal view {
        if (deadline >= block.timestamp) {
            revert ProjectStillFunding();
        }
    }

    function _distribute(
        uint256 _artistFee,
        uint256 _advisoryFee,
        uint256 _platformFee,
        address _nftContract,
        uint256 _tokenPrice
    ) internal {
        address artist = NFT(_nftContract).artist();
        address advisory = Token(token).advisory();
        address platform = Token(token).platform();

        IERC20(token).transfer(artist, _count(_tokenPrice, _artistFee));
        IERC20(token).transfer(advisory, _count(_tokenPrice, _advisoryFee));
        IERC20(token).transfer(platform, _count(_tokenPrice, _platformFee));
    }

    function _count(
        uint256 amount,
        uint256 bps
    ) internal pure returns (uint256) {
        return (amount * bps) / 10_000;
    }

    function _generateLeaf(
        bytes memory _encoded
    ) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(_encoded)));
    }
}
