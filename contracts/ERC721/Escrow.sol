// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

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
contract Escrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    struct Project {
        bool initiated;
        uint256 finalCap;
        uint256 deadline;
        bool durationChanged;
        Capstone soft;
        Capstone medium;
        Capstone hard;
    }
    struct Capstone {
        // Cap for the project
        uint256 cap;
        // Current total from user transfer
        uint256 total;
        // Filled status for each cap
        bool filled;
        // mapping(address => uint256) private _deposits;
        mapping(address => uint256) map;
    }

    mapping(address => Project) private nftEscrow;

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
        nftEscrow[nftContract].soft.cap = soft;
        nftEscrow[nftContract].medium.cap = medium;
        nftEscrow[nftContract].hard.cap = hard;
    }

    function _deposit(
        uint256 amount,
        address nftContract,
        Capstone storage capstone
    ) internal {
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            amount
        );
        capstone.total += amount;
        capstone.map[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
        if (capstone.total >= capstone.cap) {
            capstone.filled = true;
            nftEscrow[nftContract].finalCap = capstone.cap;
        }
    }

    function _addSurplus(
        Capstone storage lowerCapstone,
        Capstone storage higherCapstone
    ) internal {
        if (lowerCapstone.total >= lowerCapstone.cap) {
            higherCapstone.total += lowerCapstone.total - lowerCapstone.cap;
        }
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param amount The amount that needed to be transferred by the user.
     *
     * Emits a {Deposited} event.
     */
    function deposit(uint256 amount, address nftContract)
        public
        payable
        virtual
        onlyOwner
    {
        // uint256 amount = msg.value;
        // _deposits[payee] += amount;
        // emit Deposited(payee, amount);
        require(nftEscrow[nftContract].initiated, "Project not initiated");
        require(!nftEscrow[nftContract].hard.filled, "Project fully supported");
        if (!nftEscrow[nftContract].soft.filled) {
            _deposit(amount, nftContract, nftEscrow[nftContract].soft);
            _addSurplus(
                nftEscrow[nftContract].soft,
                nftEscrow[nftContract].medium
            );
        } else if (!nftEscrow[nftContract].medium.filled) {
            _deposit(amount, nftContract, nftEscrow[nftContract].medium);
            _addSurplus(
                nftEscrow[nftContract].medium,
                nftEscrow[nftContract].hard
            );
        } else if (!nftEscrow[nftContract].hard.filled) {
            _deposit(amount, nftContract, nftEscrow[nftContract].hard);
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
            if (nftEscrow[nftContract].hard.filled) {
                return 0;
            } else if (nftEscrow[nftContract].medium.filled) {
                uint256 payment = nftEscrow[nftContract].hard.map[msg.sender];
                return payment;
            } else if (nftEscrow[nftContract].soft.filled) {
                uint256 payment = nftEscrow[nftContract].medium.map[msg.sender];
                return payment;
            } else {
                uint256 payment = nftEscrow[nftContract].soft.map[msg.sender];
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
        if (nftEscrow[nftContract].hard.filled) {} else if (
            nftEscrow[nftContract].medium.filled
        ) {
            uint256 payment = nftEscrow[nftContract].hard.map[msg.sender];
            delete nftEscrow[nftContract].hard.map[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else if (nftEscrow[nftContract].soft.filled) {
            uint256 payment = nftEscrow[nftContract].medium.map[msg.sender];
            delete nftEscrow[nftContract].medium.map[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else {
            uint256 payment = nftEscrow[nftContract].soft.map[msg.sender];
            delete nftEscrow[nftContract].soft.map[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        }
    }

    function transferBalance() external onlyOwner {}

    function getCapstone(address nftContract) public view returns (uint256) {
        return nftEscrow[nftContract].finalCap;
    }
}
