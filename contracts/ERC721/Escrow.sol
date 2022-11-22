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
contract Escrow is Ownable, ReentrancyGuard {
    using Address for address payable;

    event Deposited(
        address indexed payee,
        uint256 talaxAmount,
        address nftContract,
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
    struct Project {
        Status status;
        bool initiated;
        bool durationChanged;
        uint256 deadline;
        uint256 totalDeposit;
        uint256 softCap;
        uint256 mediumCap;
        uint256 hardCap;
        uint256 finalCap;
        mapping(Status => mapping(uint256 => address)) tokenToUser;
        mapping(Status => mapping(address => uint256)) userTotalDeposits;
    }

    mapping(address => Project) private nftProjects;
    address private token;

    constructor(address _token) {
        token = _token;
    }

    function initiateNFTProject(
        address nftContract,
        uint256 duration,
        uint256 soft,
        uint256 medium,
        uint256 hard
    ) external onlyOwner {
        require(!nftProjects[nftContract].initiated, "Project was initiated");
        nftProjects[nftContract].deadline = duration + block.timestamp;
        nftProjects[nftContract].softCap = soft;
        nftProjects[nftContract].mediumCap = medium;
        nftProjects[nftContract].hardCap = hard;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param nftContract The nft contract address of the NFT that chosen by the msg.sender
     * @param tokenId The tokenId of the NFT that chosen by the msg.sender
     * @param amount The amount deposited in TALAX of the NFT price that chosen by the msg.sender
     *
     * Emits a {Deposited} event.
     */
    function deposit(
        address nftContract,
        uint256 tokenId,
        uint256 amount
    ) public nonReentrant {
        Project storage project = nftProjects[nftContract];
        require(project.initiated, "Project not initiated");
        require(project.status != Status.Hard, "Project fully supported");

        // Deposit for the current status
        project.userTotalDeposits[project.status][msg.sender] += amount;
        // Add to total amount for tracking
        project.totalDeposit += amount;
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            amount
        );

        // Check if total surpass any capstone
        if (project.totalDeposit >= project.hardCap) {
            project.status = Status.NonQualified;
            project.finalCap = project.hardCap;
        } else if (project.totalDeposit >= project.mediumCap) {
            project.status = Status.Hard;
            project.finalCap = project.mediumCap;
        } else if (project.totalDeposit >= project.softCap) {
            project.status = Status.Medium;
            project.finalCap = project.softCap;
        }

        emit Deposited(msg.sender, amount, nftContract, tokenId);
    }

    function withdrawalAllowed(address nftContract) public view returns (bool) {
        if (nftProjects[nftContract].deadline < block.timestamp) {
            return true;
        }
        return false;
    }

    function getWithdrawalAble(address nftContract)
        public
        view
        returns (uint256)
    {
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
        SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
        emit Withdrawn(msg.sender, payment, nftContract);
    }

    function claimNFT(address nftContract, uint256 tokenId)
        public
        nonReentrant
    {
        Project storage project = nftProjects[nftContract];
        // Check if Crowdfund success
        require(project.status != Status.Soft, "Crowdfund Failed");
        // Check if msg.sender is depositor
        address soft = project.tokenToUser[Status.Soft][tokenId];
        address medium = project.tokenToUser[Status.Medium][tokenId];
        address hard = project.tokenToUser[Status.Hard][tokenId];

        if (project.status == Status.NonQualified) {
            require(
                soft == msg.sender ||
                    medium == msg.sender ||
                    hard == msg.sender,
                "Not Authorized"
            );
        } else if (project.status == Status.Hard) {
            require(
                soft == msg.sender || medium == msg.sender,
                "Not Authorized"
            );
        } else {
            require(soft == msg.sender, "Not Authorized");
        }
        // Transfer from first owner(platform administrator) to msg.sender
        // NFT first owner have to approve right after minting process
        address owner = IERC721(nftContract).ownerOf(tokenId);
        IERC721(nftContract).transferFrom(owner, msg.sender, tokenId);
        emit NFTClaimed(msg.sender, nftContract, tokenId);
    }

    function getCapstone(address nftContract) public view returns (uint256) {
        return nftProjects[nftContract].finalCap;
    }
}
