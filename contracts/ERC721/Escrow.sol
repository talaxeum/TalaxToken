// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

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

interface Token {
    function taxRate() external returns (uint256);
}

// TODO: Change the functions based on who mints the NFT (tokenID or tokenURI for tracking who picks the NFT)
contract Escrow is Ownable, ReentrancyGuard {
    using Address for address payable;

    event Deposited(
        address indexed payee,
        uint256 talaxAmount,
        address nftContract,
        Status status,
        uint256 tokenId
    );
    event Withdrawn(
        address indexed payee,
        uint256 talaxAmount,
        address nftContract
    );
    event NFTClaimed(
        address indexed payee,
        address indexed nftContract,
        uint256 tokenId
    );

    enum Status {
        Soft,
        Medium,
        Hard,
        NonQualified
    }

    // TODO: use this to distribute the deposited token
    struct Cap {
        uint256 softCap;
        uint256 mediumCap;
        uint256 hardCap;
        uint256 finalCap;
    }
    struct NFTData {
        address payee;
        address artist;
    }
    struct Beneficiaries {
        uint256 projectWallet;
        uint256 advisory;
        uint256 platform;
    }
    struct Project {
        bool initiated;
        bool durationChanged;
        uint256 deadline;
        uint256 totalDeposit;
        uint256 tokenPrice;
        Status status;
        Cap capstone;
        Beneficiaries benefs;
        mapping(Status => mapping(uint256 => NFTData)) tokenIdToData;
        mapping(Status => mapping(address => uint256)) userTotalDeposits;
    }

    mapping(address => Project) private nftProjects;
    address private token;
    address private advisory;
    address private platform;

    constructor(address _token) {
        token = _token;
    }

    function initiateNFTProject(
        address _nftContract,
        uint256 _duration,
        uint256 _soft,
        uint256 _medium,
        uint256 _hard,
        uint256 _projectWallet,
        uint256 _advisory,
        bool _isCommercial,
        uint256 _tokenPrice
    ) external onlyOwner {
        require(!nftProjects[_nftContract].initiated, "Project was initiated");
        Project storage project = nftProjects[_nftContract];
        project.deadline = _duration + block.timestamp;
        project.capstone.softCap = _soft;
        project.capstone.mediumCap = _medium;
        project.capstone.hardCap = _hard;
        project.tokenPrice = _tokenPrice;

        require(
            _advisory >= 2 && _projectWallet <= 5,
            "Advisory only between 2% and 5%"
        );

        if (_isCommercial) {
            require(
                _projectWallet >= 77 && _projectWallet <= 80,
                "Project Wallet only between 77% and 80%"
            );
            project.benefs.platform = 8;
        } else {
            require(
                _projectWallet >= 80 && _projectWallet <= 83,
                "Project Wallet only between 77% and 80%"
            );
            project.benefs.platform = 5;
        }

        project.benefs.projectWallet = _projectWallet;
        project.benefs.advisory = _advisory;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param _nftContract The nft contract address of the NFT that chosen by the msg.sender
     * @param _tokenId The tokenId of the NFT that chosen by the msg.sender
     * @param _amount The amount deposited in TALAX of the NFT price that chosen by the msg.sender
     * @param _artist The address of the artist
     *
     * Emits a {Deposited} event.
     */
    function deposit(
        address _nftContract,
        uint256 _tokenId,
        uint256 _amount,
        address _artist
    ) public nonReentrant {
        Project storage project = nftProjects[_nftContract];
        Status status = project.status;
        require(project.initiated, "Project not initiated");
        require(project.status != Status.Hard, "Project fully supported");

        uint256 amountIncludeTax = ((100 - Token(token).taxRate()) * _amount) /
            100;

        // Deposit for the current status
        project.userTotalDeposits[status][msg.sender] += amountIncludeTax;
        // TODO: track selected NFT
        project.tokenIdToData[status][_tokenId].payee = msg.sender;
        project.tokenIdToData[status][_tokenId].artist = _artist;
        // Add to total amount for tracking
        project.totalDeposit += _amount;
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            _amount
        );

        // Check if total surpass any capstone
        if (project.totalDeposit >= project.capstone.hardCap) {
            project.status = Status.NonQualified;
            project.capstone.finalCap = project.capstone.hardCap;
        } else if (project.totalDeposit >= project.capstone.mediumCap) {
            project.status = Status.Hard;
            project.capstone.finalCap = project.capstone.mediumCap;
        } else if (project.totalDeposit >= project.capstone.softCap) {
            project.status = Status.Medium;
            project.capstone.finalCap = project.capstone.softCap;
        }

        emit Deposited(msg.sender, _amount, _nftContract, status, _tokenId);
    }

    function withdrawalAllowed(address nftContract) public view returns (bool) {
        if (nftProjects[nftContract].deadline < block.timestamp) {
            return true;
        }
        return false;
    }

    function getWithdrawalAble(
        address nftContract
    ) public view returns (uint256) {
        Project storage project = nftProjects[nftContract];

        if (withdrawalAllowed(nftContract)) {
            return project.userTotalDeposits[project.status][msg.sender];
        }
        return 0;
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param nftContract The nftAddress that user chose when supporting a project
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw(address nftContract) public nonReentrant {
        Project storage project = nftProjects[nftContract];

        uint256 payment = project.userTotalDeposits[project.status][msg.sender];
        delete project.userTotalDeposits[project.status][msg.sender];
        _transferTokenToAddress(msg.sender, payment);
        emit Withdrawn(msg.sender, payment, nftContract);
    }

    function claimNFT(
        address _nftContract,
        uint256 _tokenId,
        Status _nftDepositStatus
    ) public nonReentrant {
        Project storage project = nftProjects[_nftContract];
        NFTData memory data = project.tokenIdToData[_nftDepositStatus][
            _tokenId
        ];
        // Check if Crowdfund success
        require(project.status != Status.Soft, "Crowdfund Failed");
        // Check if msg.sender is depositor
        require(data.payee == msg.sender, "Not Authorized");

        // NFT first owner have to approve right after minting process
        // Transfer from first owner(platform administrator) to msg.sender
        address owner = IERC721(_nftContract).ownerOf(_tokenId);
        IERC721(_nftContract).transferFrom(owner, msg.sender, _tokenId);
        // TODO: Transfer Deposited Talax Token to beneficiaries

        emit NFTClaimed(msg.sender, _nftContract, _tokenId);
    }

    /**
     * @dev Helper functions
     */

    function getCapstone(address nftContract) public view returns (uint256) {
        return nftProjects[nftContract].capstone.finalCap;
    }

    function _transferTokenToAddress(address _to, uint256 _amount) internal {
        SafeERC20.safeTransfer(IERC20(token), _to, _amount);
    }

    function _getFee(
        uint256 _percentage,
        uint256 _tokenPrice
    ) internal pure returns (uint256) {
        return (_percentage * _tokenPrice) / 100;
    }

    function _distributeToken(
        address _nftContract,
        NFTData memory _data
    ) internal {
        Project storage project = nftProjects[_nftContract];

        uint256 artistFee = _getFee(10, project.tokenPrice);
        uint256 projectWallet = _getFee(
            project.benefs.projectWallet,
            project.tokenPrice
        );
        uint256 advisory = _getFee(project.benefs.advisory, project.tokenPrice);
        uint256 platformFee = _getFee(
            project.benefs.platform,
            project.tokenPrice
        );

        // TODO: Transfer to Artist
        _transferTokenToAddress(_data.artist, artistFee);
        // TODO: Transfer to Project Contract
        _transferTokenToAddress(_nftContract, projectWallet);
        // TODO: Transfer to Advisory
        // TODO: Transfer to Platform Address
    }
}
