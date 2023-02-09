// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface NFT {
    function tokenPrice() external returns (uint256);

    function artist() external returns (address);
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

contract Escrow is Ownable {
    using Counters for Counters.Counter;

    event DurationChanged(uint256 projectId, uint256 newDeadline);
    event ProjectCreated(
        address indexed projectOwner,
        // Capstone
        uint256 soft,
        uint256 medium,
        uint256 hard,
        // Distribution in bps
        uint256 artist,
        uint256 project,
        uint256 advisory,
        uint256 platform
    );
    event Deposit(
        address indexed payee,
        uint256 projectId,
        address nftContract,
        bytes32 tokenUri,
        uint256 price
    );
    event CapstoneReached(uint256 indexed projectId, uint8 status);
    event NftMinted(
        address indexed minter,
        uint256 projectId,
        address nftContract,
        bytes32 tokenUri
    );
    event Withdraw(
        address indexed withdrawer,
        uint256 projectId,
        uint256 amount
    );
    event FundClaimed(
        address indexed claimer,
        uint256 projectId,
        uint256 amount
    );

    struct Project {
        //Cap
        // uint256 soft;
        // uint256 medium;
        // uint256 hard;
        uint256 finalCap;
        //Fee
        uint256 artist;
        uint256 project;
        uint256 advisory;
        uint256 platform;
        //Info
        uint256 totalDeposit;
        uint256 deadline;
        bytes32 projectRoot;
        uint8 status;
        address owner;
    }

    Counters.Counter private projectIds;
    mapping(uint256 => Project) private projects;
    // USed to track if NFT has been picked
    bytes32 public globalNftRoot;

    address public talax;

    constructor(address _talax) {
        talax = _talax;
    }

    /* ------------------------------------------ Functions ----------------------------------------- */
    function createProject(
        address _owner,
        uint256 _soft,
        uint256 _medium,
        uint256 _hard,
        uint256 _artist,
        uint256 _project,
        uint256 _advisory,
        uint256 _platform,
        uint256 _duration
    ) external onlyOwner {
        projectIds.increment();
        projects[projectIds.current()] = Project({
            owner: _owner,
            // soft: _soft,
            // medium: _medium,
            // hard: _hard,
            finalCap: 0,
            artist: _artist,
            project: _project,
            advisory: _advisory,
            platform: _platform,
            totalDeposit: 0,
            status: 0,
            deadline: block.timestamp + _duration,
            projectRoot: ""
        });

        emit ProjectCreated(
            _owner,
            _soft,
            _medium,
            _hard,
            _artist,
            _project,
            _advisory,
            _platform
        );
    }

    // Need to be called every time a project change status
    function updateProjectRoot(
        uint256 _projectId,
        bytes32 _root,
        bytes32 _globalNftRoot
    ) public onlyOwner {
        projects[_projectId].projectRoot = _root;
        globalNftRoot = _globalNftRoot;
    }

    // Only called by owner, owner handle the gas fee
    function deposit(
        uint256 _projectId,
        address _nftContract,
        address _depositor,
        bytes32 _tokenUri,
        uint8 _status
    ) public onlyOwner {
        Project storage project = projects[_projectId];
        if (project.status == 3) revert ProjectSuccessfullyFunded();
        if (project.deadline <= block.timestamp) revert ProjectHasEnded();

        uint256 tokenPrice = NFT(_nftContract).tokenPrice();
        project.totalDeposit += tokenPrice;

        if (project.status < _status) {
            project.status = _status;
            project.finalCap = project.totalDeposit;
            emit CapstoneReached(_projectId, project.status);
        }

        IERC20(talax).transferFrom(_depositor, address(this), tokenPrice);
        emit Deposit(
            _depositor,
            _projectId,
            _nftContract,
            _tokenUri,
            tokenPrice
        );
    }

    function withdraw(
        bytes32[] memory _proof,
        uint256 _projectId,
        uint256 _amount
    ) public {
        Project memory project = projects[_projectId];
        if (project.deadline > block.timestamp) revert ProjectStillFunding();

        // Merkle Proof to check user is a depositor
        bytes32 leaf = _generateLeaf(abi.encode(_projectId, msg.sender));
        if (!MerkleProof.verify(_proof, project.projectRoot, leaf)) {
            revert InvalidProof();
        }

        IERC20(talax).transfer(msg.sender, _amount);
    }

    function mintNft(
        bytes32[] memory _proof,
        uint256 _projectId,
        address _nftContract,
        bytes32 _tokenUri
    ) public isRunning(_projectId) returns (bool) {
        Project memory project = projects[_projectId];
        // Merkle Proof to check user has already been picked this NFT
        bytes32 leaf = _generateLeaf(
            abi.encode(_projectId, _nftContract, _tokenUri, msg.sender)
        );
        if (!MerkleProof.verify(_proof, project.projectRoot, leaf)) {
            revert InvalidProof();
        }

        // Distribute Talax
        _distribute(
            project.artist,
            project.advisory,
            project.platform,
            _nftContract,
            NFT(_nftContract).tokenPrice()
        );

        emit NftMinted(msg.sender, _projectId, _nftContract, _tokenUri);
        return true;
    }

    function claimFunding(uint256 _projectId) public isRunning(_projectId) {
        if (msg.sender != projects[_projectId].owner) revert NotOwner();
        Project memory project = projects[_projectId];
        if (project.status == 0) revert ProjectFailed();

        uint256 amount = (project.project * project.finalCap) / 10_000;

        IERC20(talax).transfer(msg.sender, amount);

        emit FundClaimed(msg.sender, _projectId, amount);
    }

    function terminateProject(
        uint256 _projectId
    ) external onlyOwner isRunning(_projectId) {
        Project storage project = projects[_projectId];
        if (project.status > 0) revert ProjectSuccessfullyFunded();

        delete project.projectRoot;
    }

    function changeDuration(
        uint256 _projectId,
        uint256 _additionalTime
    ) external onlyOwner {
        if (projects[_projectId].deadline <= block.timestamp) {
            revert ProjectHasEnded();
        }
        projects[_projectId].deadline += _additionalTime;

        emit DurationChanged(_projectId, projects[_projectId].deadline);
    }

    function getProject(
        uint256 _projectId
    ) external view returns (Project memory) {
        return projects[_projectId];
    }

    /* ------------------------------------- Internal Functions ------------------------------------- */

    function _distribute(
        uint256 _artistFee,
        uint256 _advisoryFee,
        uint256 _platformFee,
        address _nftContract,
        uint256 _tokenPrice
    ) internal {
        address artist = NFT(_nftContract).artist();
        address advisory = Token(talax).advisory();
        address platform = Token(talax).platform();

        IERC20(talax).transfer(artist, (_artistFee * _tokenPrice) / 10_000);
        IERC20(talax).transfer(advisory, (_advisoryFee * _tokenPrice) / 10_000);
        IERC20(talax).transfer(platform, (_platformFee * _tokenPrice) / 10_000);
    }

    function _generateLeaf(
        bytes memory _encoded
    ) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(_encoded)));
    }

    /* ------------------------------------------ Modifiers ----------------------------------------- */

    function _isRunning(uint256 _projectId) internal view {
        if (projects[_projectId].deadline >= block.timestamp) {
            revert ProjectStillFunding();
        }
    }

    modifier isRunning(uint256 _projectId) {
        _isRunning(_projectId);
        _;
    }
}
