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
    bool public softFilled;
    bool public mediumFilled;
    bool public hardFilled;
    // Duration in seconds and if the duration is changed by admin
    uint256 public deadline;
    bool public durationChanged;

    // mapping(address => uint256) private _deposits;
    mapping(address => uint256) private _softMap;
    mapping(address => uint256) private _mediumMap;
    mapping(address => uint256) private _hardMap;

    address private token;

    // function depositsOf(address payee) public view returns (uint256) {
    //     return _deposits[payee];
    // }

    function init(address _token) external {
        require(token == address(0), "Initiated");
        token = _token;
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param amount The amount that needed to be transferred by the user.
     *
     * Emits a {Deposited} event.
     */
    function deposit(uint256 amount) public payable virtual onlyOwner {
        // uint256 amount = msg.value;
        // _deposits[payee] += amount;
        // emit Deposited(payee, amount);
        require(!hardFilled, "Project fully supported");
        if (!softFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            softTotal += amount;
            _softMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (softTotal >= softCap) {
                softFilled = true;
                finalCap = softCap;
            }
        } else if (!mediumFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            mediumTotal += amount;
            _mediumMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (mediumTotal >= mediumCap + softCap) {
                mediumFilled = true;
                finalCap = mediumCap;
            }
        } else if (!hardFilled) {
            SafeERC20.safeTransferFrom(
                IERC20(token),
                msg.sender,
                address(this),
                amount
            );
            hardTotal += amount;
            _hardMap[msg.sender] += amount;
            emit Deposited(msg.sender, amount);
            if (hardTotal >= hardCap + mediumCap + softCap) {
                hardFilled = true;
                finalCap = hardCap;
            }
        } else {}
    }

    function withdrawalAllowed() public view virtual returns (bool) {
        if (deadline < block.timestamp) {
            return true;
        }
        return false;
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
        require(withdrawalAllowed(), "Crowdfunding is running");
        // uint256 payment = _deposits[payee];
        // _deposits[payee] = 0;
        // payee.sendValue(payment);
        // emit Withdrawn(payee, payment);
        if (hardFilled) {} else if (mediumFilled) {
            uint256 payment = _hardMap[msg.sender];
            delete _hardMap[msg.sender];
            SafeERC20.safeTransfer(IERC20(token), msg.sender, payment);
            emit Withdrawn(msg.sender, payment);
        } else if (softFilled) {
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
}
