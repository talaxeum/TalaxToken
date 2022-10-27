// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./ProjectNameNFT.sol";

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
contract ProjectNameEscrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    // Cap for the project
    uint256 public softCap;
    uint256 public mediumCap;
    uint256 public hardCap;
    uint256 public finalCap;
    // Current total from user transfer
    uint256 public softTotal;
    uint256 public mediumTotal;
    uint256 public hardTotal;
    // Filled status for each cap
    // Default status is Rejected
    enum Status {
        Rejected,
        Soft,
        Medium,
        Hard
    }
    Status public status;
    // Duration in seconds and if the duration is changed by admin
    uint256 public started;
    uint256 public duration;
    bool public durationChanged;
    // mapping(address => uint256) private _deposits;
    mapping(address => uint256) private _softMap;
    mapping(address => uint256) private _mediumMap;
    mapping(address => uint256) private _hardMap;
    // NFT mapping
    mapping(string => address) private _nftSoft;
    mapping(string => address) private _nftMedium;
    mapping(string => address) private _nftHard;

    address public token;
    address public nftContract;

    // function depositsOf(address payee) public view returns (uint256) {
    //     return _deposits[payee];
    // }

    function init(
        address _token,
        address _nftContract,
        uint256 _duration,
        uint256 _soft,
        uint256 _medium,
        uint256 _hard
    ) external {
        require(token == address(0), "Initiated");
        token = _token;
        nftContract = _nftContract;
        started = block.timestamp;
        duration = _duration;
        softCap = _soft;
        mediumCap = _medium;
        hardCap = _hard;
    }

    function getStatus() public view returns (Status) {
        return status;
    }

    function changeDuration(uint256 _duration) external onlyOwner {
        require(!durationChanged, "Duration Changed");
        duration = _duration;
        durationChanged = true;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param amount The amount that needed to be transferred by the user.
     *
     * Emits a {Deposited} event.
     */
    function deposit(uint256 amount, string memory tokenURI)
        public
        payable
        virtual
    {
        // uint256 amount = msg.value;
        // _deposits[payee] += amount;
        // emit Deposited(payee, amount);
        require(status != Status.Hard, "Project fully supported");
        if (status == Status.Rejected) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            softTotal += amount;
            _softMap[msg.sender] += amount;
            _nftSoft[tokenURI] = msg.sender;
            emit Deposited(msg.sender, amount);
            if (softTotal >= softCap) {
                status = Status.Soft;
                finalCap = softCap;
            }
        } else if (status == Status.Soft) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            mediumTotal += amount;
            _mediumMap[msg.sender] += amount;
            _nftMedium[tokenURI] = msg.sender;
            emit Deposited(msg.sender, amount);
            if (mediumTotal >= mediumCap + softCap) {
                status = Status.Medium;
                finalCap = mediumCap;
            }
        } else if (status == Status.Medium) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            hardTotal += amount;
            _hardMap[msg.sender] += amount;
            _nftHard[tokenURI] = msg.sender;
            emit Deposited(msg.sender, amount);
            if (hardTotal >= hardCap + mediumCap + softCap) {
                status = Status.Hard;
                finalCap = hardCap;
            }
        } else {}
    }

    function _withdrawalAllowed() internal view virtual returns (bool) {
        uint256 deadline = started + duration;
        if (deadline < block.timestamp) {
            return true;
        }
        return false;
    }

    function getTotalWithdraw() external view returns (uint256) {
        if (status == Status.Medium) {
            uint256 amount = _hardMap[msg.sender];
            return amount;
        } else if (status == Status.Soft) {
            uint256 amount = _mediumMap[msg.sender];
            return amount;
        } else {
            uint256 amount = _softMap[msg.sender];
            return amount;
        }
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw() public virtual {
        require(_withdrawalAllowed(), "Crowdfunding is running");
        require(status != Status.Hard, "Non Withdrawable");
        // uint256 payment = _deposits[payee];
        // _deposits[payee] = 0;
        // payee.sendValue(payment);
        // emit Withdrawn(payee, payment);
        if (status == Status.Medium) {
            uint256 payment = _hardMap[msg.sender];
            delete _hardMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else if (status == Status.Soft) {
            uint256 payment = _mediumMap[msg.sender];
            delete _mediumMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else {
            uint256 payment = _softMap[msg.sender];
            delete _softMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        }
    }

    function transferEscrowBalance(address to) external onlyOwner {
        require(_withdrawalAllowed(), "Crowdfunding is running");
        uint256 balance = IERC20(token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(token), to, balance);
    }

    function _mintAllowed(string memory tokenURI) internal view returns (bool) {
        Status _status = getStatus();

        if (_status == Status.Hard) {
            if (_nftHard[tokenURI] != address(0)) {
                return true;
            } else if (_nftMedium[tokenURI] != address(0)) {
                return true;
            } else if (_nftSoft[tokenURI] != address(0)) {
                return true;
            } else {
                return false;
            }
        } else if (_status == Status.Medium) {
            if (_nftMedium[tokenURI] != address(0)) {
                return true;
            } else if (_nftSoft[tokenURI] != address(0)) {
                return true;
            } else {
                return false;
            }
        } else if (_status == Status.Soft) {
            if (_nftSoft[tokenURI] != address(0)) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function mintNFT(
        string memory tokenURI,
        address artist,
        uint256 price
    ) external {
        require(_withdrawalAllowed(), "Crowdfunding is running");
        require(_mintAllowed(tokenURI), "This NFT is not Allowed");
        ProjectNameNFT(nftContract).mintNFTWithRoyalty(
            msg.sender,
            tokenURI,
            artist,
            price
        );
    }
}
