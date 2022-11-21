// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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
contract NFTEscrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    struct Project {
        bool initiated;
        // Cap for the project
        uint256 softCap;
        uint256 mediumCap;
        uint256 hardCap;
        uint256 finalCap;
        // Current total from user transfer
        uint256 softTotal;
        uint256 mediumTotal;
        uint256 hardTotal;
        // Filled status for each cap
        bool softFilled;
        bool mediumFilled;
        bool hardFilled;
        // Duration in seconds and if the duration is changed by admin
        uint256 deadline;
        bool durationChanged;
        // mapping(address => uint256) private _deposits;
        mapping(address => uint256) _softMap;
        mapping(address => uint256) _mediumMap;
        mapping(address => uint256) _hardMap;
    }

    mapping(address => Project) public nftEscrow;

    address private token;

    // function depositsOf(address payee) public view returns (uint256) {
    //     return _deposits[payee];
    // }

    function init(address _token) external {
        require(token == address(0), "Initiated");
        token = _token;
    }

    function initiateNFTProject(
        address nftContract,
        uint256 duration,
        uint256 soft,
        uint256 medium,
        uint256 hard
    ) external onlyOwner {
        require(!nftEscrow[nftContract].initiated, "Project was initiated");
        nftEscrow[nftContract].deadline = duration + block.timestamp;
        nftEscrow[nftContract].softCap = soft;
        nftEscrow[nftContract].mediumCap = medium;
        nftEscrow[nftContract].hardCap = hard;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param amount The amount that needed to be transferred by the user.
     *
     * Emits a {Deposited} event.
     */
    function deposit(address nftContract, uint256 amount)
        public
        payable
        virtual
        onlyOwner
    {
        // uint256 amount = msg.value;
        // _deposits[payee] += amount;
        // emit Deposited(payee, amount);
        require(nftEscrow[nftContract].initiated, "Project not initiated");
        require(!nftEscrow[nftContract].hardFilled, "Project fully supported");
        if (!nftEscrow[nftContract].softFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            nftEscrow[nftContract].softTotal += amount;
            nftEscrow[nftContract]._softMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (
                nftEscrow[nftContract].softTotal >=
                nftEscrow[nftContract].softCap
            ) {
                nftEscrow[nftContract].softFilled = true;
                nftEscrow[nftContract].finalCap = nftEscrow[nftContract]
                    .softCap;
            }
        } else if (!nftEscrow[nftContract].mediumFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            nftEscrow[nftContract].mediumTotal += amount;
            nftEscrow[nftContract]._mediumMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (
                nftEscrow[nftContract].mediumTotal >=
                nftEscrow[nftContract].mediumCap
            ) {
                nftEscrow[nftContract].mediumFilled = true;
                nftEscrow[nftContract].finalCap = nftEscrow[nftContract]
                    .mediumCap;
            }
        } else if (!nftEscrow[nftContract].hardFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            nftEscrow[nftContract].hardTotal += amount;
            nftEscrow[nftContract]._hardMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (
                nftEscrow[nftContract].hardTotal >=
                nftEscrow[nftContract].hardCap
            ) {
                nftEscrow[nftContract].hardFilled = true;
                nftEscrow[nftContract].finalCap = nftEscrow[nftContract]
                    .hardCap;
            }
        } else {}
    }

    function withdrawalAllowed(address nftContract)
        public
        view
        virtual
        returns (bool)
    {
        if (nftEscrow[nftContract].deadline < block.timestamp) {
            return true;
        }
        return false;
    }

    function getWithdrawalAble(address nftContract)
        public
        view
        returns (uint256)
    {
        if (nftEscrow[nftContract].deadline < block.timestamp) {
            if (nftEscrow[nftContract].hardFilled) {
                return 0;
            } else if (nftEscrow[nftContract].mediumFilled) {
                uint256 payment = nftEscrow[nftContract]._hardMap[msg.sender];
                return payment;
            } else if (nftEscrow[nftContract].softFilled) {
                uint256 payment = nftEscrow[nftContract]._mediumMap[msg.sender];
                return payment;
            } else {
                uint256 payment = nftEscrow[nftContract]._softMap[msg.sender];
                return payment;
            }
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
     * Emits a {Withdrawn} event.
     */
    function withdraw(address nftContract) public virtual {
        require(withdrawalAllowed(nftContract), "Crowdfunding is running");
        // uint256 payment = _deposits[payee];
        // _deposits[payee] = 0;
        // payee.sendValue(payment);
        // emit Withdrawn(payee, payment);
        if (nftEscrow[nftContract].hardFilled) {} else if (
            nftEscrow[nftContract].mediumFilled
        ) {
            uint256 payment = nftEscrow[nftContract]._hardMap[msg.sender];
            delete nftEscrow[nftContract]._hardMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else if (nftEscrow[nftContract].softFilled) {
            uint256 payment = nftEscrow[nftContract]._mediumMap[msg.sender];
            delete nftEscrow[nftContract]._mediumMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else {
            uint256 payment = nftEscrow[nftContract]._softMap[msg.sender];
            delete nftEscrow[nftContract]._softMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        }
    }

    function transferBalance() external onlyOwner {}

    function getCapstone(address nftContract) public view returns (uint256) {
        return nftEscrow[nftContract].finalCap;
    }
}
