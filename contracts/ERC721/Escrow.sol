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

contract MultiEscrow is Ownable {
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
        bytes32 nftMerkleRoot;
        bytes32 depositMerkleRoot;
        uint8 status;
        address owner;
    }

    Counters.Counter private projectIds;
    mapping(uint256 => Project) private projects;
    // USed to track if NFT has been picked
    bytes32 private globalNftMerkleRoot;

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
            nftMerkleRoot: "",
            depositMerkleRoot: ""
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

    function deposit(
        bytes32[] memory _proof,
        uint256 _projectId,
        address _nftContract,
        bytes32 _tokenUri,
        uint8 _status,
        bytes32 _depositMerkleRoot,
        bytes32 _nftMerkleRoot,
        bytes32 _newGlobalNftRoot
    ) public {
        Project storage project = projects[_projectId];
        require(project.status < 3, "Project has been funded");
        require(project.deadline > block.timestamp, "Project is running");

        bytes32 leaf = _generateLeaf(abi.encode(_projectId, _tokenUri));
        require(
            !MerkleProof.verify(_proof, globalNftMerkleRoot, leaf),
            "Invalid proof"
        );

        uint256 tokenPrice = NFT(_nftContract).tokenPrice();
        project.totalDeposit += tokenPrice;

        if (_depositMerkleRoot != "") {
            project.depositMerkleRoot = _depositMerkleRoot;
        }
        if (project.status < _status) {
            project.status = _status;
            project.finalCap = project.totalDeposit;
            project.nftMerkleRoot = _nftMerkleRoot;
            if (_newGlobalNftRoot != "") {
                globalNftMerkleRoot = _newGlobalNftRoot;
            }
            emit CapstoneReached(_projectId, project.status);
        }

        IERC20(talax).transferFrom(msg.sender, address(this), tokenPrice);
        emit Deposit(
            msg.sender,
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
        require(project.deadline < block.timestamp, "Project is running");

        // Merkle Proof to check user is a depositor
        bytes32 leaf = _generateLeaf(abi.encode(_projectId, msg.sender));
        require(
            MerkleProof.verify(_proof, project.depositMerkleRoot, leaf),
            "Invalid proof"
        );

        IERC20(talax).transfer(msg.sender, _amount);
    }

    function mintNft(
        bytes32[] memory _proof,
        uint256 _projectId,
        address _nftContract,
        bytes32 _tokenUri
    ) public returns (bool) {
        Project memory project = projects[_projectId];
        // Merkle Proof to check user has already been picked this NFT
        bytes32 leaf = _generateLeaf(
            abi.encode(_projectId, _nftContract, _tokenUri, msg.sender)
        );
        require(
            MerkleProof.verify(_proof, project.depositMerkleRoot, leaf),
            "Invalid proof"
        );

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
        Project memory project = projects[_projectId];
        require(project.status > 0, "Project failed");
        require(msg.sender == project.owner, "Not Authorized");

        uint256 amount = (project.project * project.finalCap) / 10_000;

        IERC20(talax).transfer(msg.sender, amount);

        emit FundClaimed(msg.sender, _projectId, amount);
    }

    function terminateProject(uint256 projectId) external onlyOwner {
        Project storage project = projects[projectId];
        require(projects[projectId].status == 0, "Project successfully funded");
        delete project.nftMerkleRoot;
    }

    function changeDuration(
        uint256 _projectId,
        uint256 _additionalTime
    ) external onlyOwner {
        projects[_projectId].deadline += _additionalTime;

        emit DurationChanged(_projectId, projects[_projectId].deadline);
    }

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

    function getProject(
        uint256 _projectId
    ) external view returns (Project memory) {
        return projects[_projectId];
    }

    function _generateLeaf(
        bytes memory _encoded
    ) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(_encoded)));
    }

    /* ------------------------------------------ Modifiers ----------------------------------------- */

    function _isRunning(uint256 _projectId) internal view {
        require(
            projects[_projectId].deadline < block.timestamp,
            "Project is still funding"
        );
    }

    modifier isRunning(uint256 _projectId) {
        _isRunning(_projectId);
        _;
    }
}
