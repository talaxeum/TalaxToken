// SPDX-License-Identifier: MIT
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

interface NFT {
    function tokenPrice() external returns (uint256);
}

interface Token {
    function advisory() external returns (address);

    function platform() external returns (address);
}

contract ProjectEscrow is Ownable {
    using Address for address payable;

    event Deposited(
        address indexed payee,
        address indexed projectContract,
        uint256 talaxAmount,
        address nftContract,
        Status status,
        uint256 tokenId
    );
    event Withdrawn(
        address indexed payee,
        address indexed projectContract,
        uint256 talaxAmount
    );
    event NFTClaimed(
        address indexed payee,
        address indexed projectContract,
        address indexed nftContract,
        uint256 tokenId
    );

    enum Status {
        Soft,
        Medium,
        Hard,
        NonQualified
    }

    struct Cap {
        uint256 softCap;
        uint256 mediumCap;
        uint256 hardCap;
        uint256 finalCap;
    }

    bool private _durationChanged;
    uint256 private _deadline;
    uint256 private _totalDeposit;
    Status private _status;
    Cap private _capstone;

    address private _token;

    // Mapping for tracking Status => nft contract => user address => tokenIds
    mapping(Status => mapping(address => mapping(address => uint256[])))
        private _selectedNFTs;
    // Mapping for tracking total deposits for each Status/Capstone
    mapping(Status => mapping(address => uint256)) private _userDeposits;

    // TODO: restructure for single project escrow contract
    // TODO: constructor for initiate the project
    constructor() {}

    function init(address token) external {
        _token = token;
    }

    modifier isRunning() {
        _isRunning();
        _;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     *
     * Emits a {Deposited} event.
     */
    function deposit(
        address nftContract,
        uint256 tokenId
    ) public payable virtual {
        require(block.timestamp < _deadline, "Project is running");
        require(_status != Status.NonQualified, "Project fully supported");

        uint256 _tokenPrice = NFT(nftContract).tokenPrice();

        // Deposit for the current status
        _userDeposits[_status][msg.sender] += _tokenPrice;
        _totalDeposit += _tokenPrice;
        // Track selected NFT
        _selectedNFTs[_status][nftContract][msg.sender].push(tokenId);
        SafeERC20.safeTransferFrom(
            IERC20(_token),
            msg.sender,
            address(this),
            _tokenPrice
        );

        // Check if total surpass any capstone
        if (_totalDeposit >= _capstone.hardCap) {
            _status = Status.NonQualified;
            _capstone.finalCap = _capstone.hardCap;
        } else if (_totalDeposit >= _capstone.mediumCap) {
            _status = Status.Hard;
            _capstone.finalCap = _capstone.mediumCap;
        } else if (_totalDeposit >= _capstone.softCap) {
            _status = Status.Medium;
            _capstone.finalCap = _capstone.softCap;
        }
        emit Deposited(
            msg.sender,
            address(this),
            _tokenPrice,
            nftContract,
            _status,
            tokenId
        );
    }

    // TODO: Create functions to mint NFT
    function mintNFTs(address nftContract) public payable isRunning {
        Status[] memory statuses = _getAvailableStatus();
        uint256[] memory tokenIds;
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw() public virtual isRunning {
        uint256 payment = _userDeposits[_status][msg.sender];
        delete _userDeposits[_status][msg.sender];
        SafeERC20.safeTransfer(IERC20(_token), msg.sender, payment);
        emit Withdrawn(msg.sender, address(this), payment);
    }

    /* ------------------------------------------- Helpers ------------------------------------------ */

    function _isRunning() internal {
        require(block.timestamp > _deadline, "Project is still funding");
    }

    function totalDepositsOf(address payee) public view returns (uint256) {
        return (_userDeposits[Status.Soft][payee] +
            _userDeposits[Status.Medium][payee] +
            _userDeposits[Status.Hard][payee] +
            _userDeposits[Status.NonQualified][payee]);
    }

    function getCapstone() public view returns (uint256) {
        return _capstone.finalCap;
    }

    function getWithdrawalAble() public view returns (uint256) {
        if (_deadline > block.timestamp) {
            return _userDeposits[_status][msg.sender];
        }
        return 0;
    }

    // TODO: confirm this function first
    // TODO: Need to be called when NFT is minted
    function _distributeToken() public {}

    function _getAvailableStatus() internal view returns (Status[] memory) {
        if (_status == Status.Medium) {
            Status[] memory statuses = new Status[](1);
            statuses[0] = Status.Soft;
            return statuses;
        } else if (_status == Status.Hard) {
            Status[] memory statuses = new Status[](2);
            statuses[0] = Status.Soft;
            statuses[1] = Status.Medium;
            return statuses;
        } else {
            Status[] memory statuses = new Status[](3);
            statuses[0] = Status.Soft;
            statuses[1] = Status.Medium;
            statuses[2] = Status.Hard;
            return statuses;
        }
    }
}
