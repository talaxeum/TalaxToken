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
        address owner;
        //Cap
        uint256 soft;
        uint256 medium;
        uint256 hard;
        uint256 finalCap;
        //Fee
        uint256 artist;
        uint256 project;
        uint256 advisory;
        uint256 platform;
        //Info
        uint256 totalDeposit;
        uint8 status;
        uint256 deadline;
        bytes32 nftMerkleRoot;
        bytes32 depositMerkleRoot;
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
            soft: _soft,
            medium: _medium,
            hard: _hard,
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
        bytes32[] memory proof,
        uint256 projectId,
        address nftContract,
        bytes32 tokenUri,
        uint8 status,
        bytes32 depositMerkleRoot,
        bytes32 nftMerkleRoot,
        bytes32 newGlobalNftRoot
    ) public {
        Project storage project = projects[projectId];
        require(
            project.status < 3 && block.timestamp < project.deadline,
            "Project has been funded"
        );

        bytes32 leaf = _generateLeaf(abi.encode(projectId, tokenUri));
        require(
            !MerkleProof.verify(proof, globalNftMerkleRoot, leaf),
            "Invalid proof"
        );

        uint256 tokenPrice = NFT(nftContract).tokenPrice();
        project.totalDeposit += tokenPrice;

        if (depositMerkleRoot != "") {
            project.depositMerkleRoot = depositMerkleRoot;
        }
        if (project.status < status) {
            project.status = status;
            project.finalCap = project.totalDeposit;
            project.nftMerkleRoot = nftMerkleRoot;
            if (newGlobalNftRoot != "") {
                globalNftMerkleRoot = newGlobalNftRoot;
            }
            emit CapstoneReached(projectId, project.status);
        }

        IERC20(talax).transferFrom(msg.sender, address(this), tokenPrice);
        emit Deposit(msg.sender, projectId, nftContract, tokenUri, tokenPrice);
    }

    function withdraw(
        bytes32[] memory proof,
        uint256 projectId,
        uint256 amount
    ) public {
        Project memory project = projects[projectId];
        require(project.deadline < block.timestamp, "Project is running");

        // Merkle Proof to check user is a depositor
        bytes32 leaf = _generateLeaf(abi.encode(projectId, msg.sender));
        require(
            MerkleProof.verify(proof, project.depositMerkleRoot, leaf),
            "Invalid proof"
        );

        IERC20(talax).transfer(msg.sender, amount);
    }

    function mintNft(
        bytes32[] memory proof,
        uint256 projectId,
        address nftContract,
        bytes32 tokenUri
    ) public returns (bool) {
        Project memory project = projects[projectId];
        // Merkle Proof to check user has already been picked this NFT
        bytes32 leaf = _generateLeaf(
            abi.encode(projectId, nftContract, tokenUri, msg.sender)
        );
        require(
            MerkleProof.verify(proof, project.depositMerkleRoot, leaf),
            "Invalid proof"
        );

        // Distribute Talax
        _distribute(
            project.artist,
            project.advisory,
            project.platform,
            nftContract,
            NFT(nftContract).tokenPrice()
        );

        emit NftMinted(msg.sender, projectId, nftContract, tokenUri);
        return true;
    }

    function claimFunding(uint256 projectId) public isRunning(projectId) {
        Project memory project = projects[projectId];
        require(project.status > 0, "Project failed");
        require(msg.sender == project.owner, "Not Authorized");

        uint256 amount = (project.project * project.finalCap) / 10_000;

        IERC20(talax).transfer(msg.sender, amount);

        emit FundClaimed(msg.sender, projectId, amount);
    }

    function terminateProject(uint256 projectId) external onlyOwner {
        Project storage project = projects[projectId];
        require(projects[projectId].status == 0, "Project successfully funded");
        delete project.nftMerkleRoot;
    }

    function _distribute(
        uint256 artistFee,
        uint256 advisoryFee,
        uint256 platformFee,
        address nftContract,
        uint256 tokenPrice
    ) internal {
        address artist = NFT(nftContract).artist();
        address advisory = Token(talax).advisory();
        address platform = Token(talax).platform();

        IERC20(talax).transfer(artist, (artistFee * tokenPrice) / 10_000);
        IERC20(talax).transfer(advisory, (advisoryFee * tokenPrice) / 10_000);
        IERC20(talax).transfer(platform, (platformFee * tokenPrice) / 10_000);
    }

    function getProject(
        uint256 projectId
    ) external view returns (Project memory) {
        return projects[projectId];
    }

    function _generateLeaf(
        bytes memory encoded
    ) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(encoded)));
    }

    /* ------------------------------------------ Modifiers ----------------------------------------- */

    function _isRunning(uint256 projectId) internal view {
        require(
            projects[projectId].deadline < block.timestamp,
            "Project is still funding"
        );
    }

    modifier isRunning(uint256 projectId) {
        _isRunning(projectId);
        _;
    }
}
