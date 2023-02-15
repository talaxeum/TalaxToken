// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error NotOwnerError();
error AlreadyQueuedError(bytes32 txId);
error TimestampNotInRangeError(uint256 blockTimestamp, uint256 timestamp);
error NotQueuedError(bytes32 txId);
error TimestampNotPassedError(uint256 blockTimestmap, uint256 timestamp);
error TimestampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
error TxFailedError();

contract TimeLock {
    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint256 value,
        bytes data,
        uint256 timestamp
    );
    event Cancel(bytes32 indexed txId);

    address public owner;
    // tx id => queued
    mapping(bytes32 => bool) public queued;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    receive() external payable {}

    function getTxId(
        address _target,
        uint256 _value,
        bytes calldata _data,
        uint256 _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _data, _timestamp));
    }

    /**
     * @param _target Address of contract or account to call
     * @param _value Amount of ETH to send
     * @param _data ABI encoded data send.
     */
    function queue(
        address _target,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bytes32 txId) {
        uint256 timestamp = block.timestamp + 48 hours;
        txId = getTxId(_target, _value, _data, timestamp);
        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }

        queued[txId] = true;

        emit Queue(txId, _target, _value, _data, timestamp);
    }

    function execute(
        address _target,
        uint256 _value,
        bytes calldata _data,
        uint256 _timestamp
    ) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _data, _timestamp);
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }
        if (block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }

        queued[txId] = false;

        // call target
        (bool ok, bytes memory res) = _target.call{value: _value}(_data);
        if (!ok) {
            revert TxFailedError();
        }

        emit Execute(txId, _target, _value, _data, _timestamp);

        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!queued[_txId]) {
            revert NotQueuedError(_txId);
        }

        queued[_txId] = false;

        emit Cancel(_txId);
    }
}
