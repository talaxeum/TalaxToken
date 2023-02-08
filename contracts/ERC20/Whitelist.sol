// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */

contract Whitelist is Context, Ownable {
    event ERC20Released(
        address indexed token,
        address indexed user,
        uint256 amount
    );

    struct Beneficiary {
        address user;
        uint256 amount;
    }

    // mapping(address => uint256) private _released;
    // address private immutable _beneficiary;
    mapping(address => uint256) private _released;
    mapping(address => uint256) _beneficiary;
    uint256 public start;
    uint256 public duration;
    address constant token = address(0); // tbd

    bytes32 private whitelistRoot;

    // uint256 private lastMonth;
    mapping(address => uint256) private _lastMonth;

    bool private _initStatus;

    constructor(uint256 _start, uint256 _duration, uint256 _cliff) {
        start = _start + _cliff;
        duration = _duration;
    }

    // Used when adding a new user in the backend
    function updateRoot(bytes32 _root) public onlyOwner {
        whitelistRoot = _root;
    }

    function vest(address user, uint256 amount) public onlyOwner {
        _beneficiary[user] += amount;
    }

    function release(bytes32[] calldata _proof) public virtual {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender)))
        );

        require(
            MerkleProof.verify(_proof, whitelistRoot, leaf),
            "Invalid proof"
        );

        uint256 amount = releasable();
        if (_currentMonth() > _lastMonth[msg.sender]) {
            _lastMonth[msg.sender] = _currentMonth();
            _beneficiary[msg.sender] -= amount;
            _released[msg.sender] += amount;
            IERC20(token).transfer(msg.sender, amount);
            emit ERC20Released(token, msg.sender, amount);
        }
    }

    /* --------------------------------------- View Functions --------------------------------------- */
    function released() public view virtual returns (uint256) {
        return _released[msg.sender];
    }

    function releasable() public view virtual returns (uint256) {
        return vestedAmount(block.timestamp) - released();
    }

    function vestedAmount(
        uint256 timestamp
    ) public view virtual returns (uint256) {
        return
            _vestingSchedule(_beneficiary[msg.sender] + released(), timestamp);
    }

    /* ------------------------------------- Internal Functions ------------------------------------- */

    function _currentMonth() internal view returns (uint256) {
        return block.timestamp - start / 30 days;
    }

    function _delete(address _user) internal {
        delete _beneficiary[_user];
    }

    function _vestingSchedule(
        uint256 totalAllocation,
        uint256 timestamp
    ) internal view virtual returns (uint256) {
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}
