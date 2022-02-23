//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

contract Multiownable {
    // VARIABLES

    uint256 public ownersGeneration;
    address[] public owners;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;

    // Reverse lookup tables for owners and allOperations
    mapping(address => uint256) public ownersIndices; // Starts from 1
    mapping(bytes32 => uint256) public allOperationsIndicies;

    // Owners voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    // EVENTS

    event OwnershipTransferred(address[] previousOwners, address[] newOwners);
    event OperationCreated(
        bytes32 operation,
        uint256 howMany,
        uint256 ownersCount,
        address proposer
    );
    event OperationUpvoted(
        bytes32 operation,
        uint256 votes,
        uint256 howMany,
        uint256 ownersCount,
        address upvoter
    );
    event OperationPerformed(
        bytes32 operation,
        uint256 howMany,
        uint256 ownersCount,
        address performer
    );

    // ACCESSORS
    function getAllOwners() public view returns (address[] memory) {
        return owners;
    }

    function isOwner(address wallet) public view returns (bool) {
        return ownersIndices[wallet] > 0;
    }

    function ownersCount() public view returns (uint256) {
        return owners.length;
    }

    function allOperationsCount() public view returns (uint256) {
        return allOperations.length;
    }

    // MODIFIERS

    /**
     * @dev Allows to perform method by any of the owners
     */
    modifier onlyAnyOwner() {
        if (checkHowManyOwners(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after all owners call it with the same arguments
     */
    modifier onlyAllOwners() {
        if (checkHowManyOwners(owners.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = owners.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() {
        owners.push(msg.sender);
        ownersIndices[msg.sender] = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManyOwners modifier helper
     */
    function checkHowManyOwners(uint256 howMany) internal returns (bool) {
        if (insideCallSender == msg.sender) {
            require(
                howMany <= insideCallCount,
                "checkHowManyOwners: nested owners modifier check require more owners"
            );
            return true;
        }

        require(
            isOwner(msg.sender) == true,
            "checkHowManyOwners: msg.sender is not an owner"
        );

        uint256 ownerIndex = ownersIndices[msg.sender] - 1;
        bytes32 operation = keccak256(
            abi.encodePacked(msg.data, ownersGeneration)
        );

        require(
            (votesMaskByOperation[operation] & (2**ownerIndex)) == 0,
            "checkHowManyOwners: owner already voted for the operation"
        );
        votesMaskByOperation[operation] |= (2**ownerIndex);
        uint256 operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;
        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            allOperations.push(operation);
            emit OperationCreated(
                operation,
                howMany,
                owners.length,
                msg.sender
            );
        }
        emit OperationUpvoted(
            operation,
            operationVotesCount,
            howMany,
            owners.length,
            msg.sender
        );

        // If enough owners confirmed the same operation
        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(
                operation,
                howMany,
                owners.length,
                msg.sender
            );
            return true;
        }

        return false;
    }

    /**
     * @dev Used to delete cancelled or performed operation
     * @param operation defines which operation to delete
     */
    function deleteOperation(bytes32 operation) internal {
        uint256 index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) {
            // Not last
            allOperations[index] = allOperations[allOperations.length - 1]; // Change Operation with last Operation in array
            allOperationsIndicies[allOperations[index]] = index;
        }

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }

    // // PUBLIC METHODS

    /**
     * @dev Allows owners to change ownership
     * @param newOwners defines array of addresses of new owners
     */
    function transferOwnership(address[] memory newOwners) public {
        transferOwnershipWithHowMany(newOwners);
    }

    /**
     * @dev Allows owners to change ownership
     * @param newOwners defines array of addresses of new owners
     */
    function transferOwnershipWithHowMany(address[] memory newOwners)
        public
        onlyAllOwners
    {
        require(
            newOwners.length > 0,
            "transferOwnershipWithHowMany: owners array is empty"
        );
        require(
            newOwners.length <= 256,
            "transferOwnershipWithHowMany: owners count is greater then 256"
        );

        // Reset owners reverse lookup table
        for (uint256 j = 0; j < owners.length; j++) {
            delete ownersIndices[owners[j]];
        }
        for (uint256 i = 0; i < newOwners.length; i++) {
            require(
                newOwners[i] != address(0),
                "transferOwnershipWithHowMany: owners array contains zero"
            );
            require(
                ownersIndices[newOwners[i]] == 0,
                "transferOwnershipWithHowMany: owners array contains duplicates"
            ); // TO Reseacrh
            ownersIndices[newOwners[i]] = i + 1;
        }

        emit OwnershipTransferred(owners, newOwners);

        owners = newOwners;
        delete allOperations;
        ownersGeneration++;
    }
}
