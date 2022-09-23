// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

struct WhitelistStruct {
    uint256 lockedAmount;
    uint256 amount;
    bool isPhase1Claimed;
    uint256 latestClaimDay;
}

struct Beneficiary {
    address user;
    uint256 amount;
}

interface IStakable {
    function stakingPenaltyRate() external view returns (uint256);

    function airdropRate() external view returns (uint256);

    function airdropSince() external view returns (uint256);

    function totalVoters() external view returns (uint256);

    function getVoters(address user) external view returns (bool, bool); // votingRight and voted

    function votedUsers(uint256 id) external view returns (uint256);

    function startAirdrop() external;

    function changeTalaxAddress(address talax) external;

    function stake(
        address user,
        uint256 amount,
        uint256 stakePeriod,
        uint256 rewardRate
    ) external;

    function changePenaltyFee(uint256 amount) external;

    function changeAirdropPercentage(uint256 amount) external;

    function withdrawStake(address user) external returns (uint256, uint256);

    function claimAirdrop(address user) external returns (uint256);

    function startVoting() external;

    function getVotingResult() external view returns (bool);

    function stopVoting() external;
}

interface IWhitelist {
    function privateSaleUsers() external view returns (uint256);

    function privateSaleAmount() external view returns (uint256);

    function startPrivateSale() external view returns (uint256);

    function changeTalaxAddress(address talax) external;

    function beneficiary(address user)
        external
        view
        returns (
            uint256,
            uint256,
            bool,
            uint256
        ); // lockedAmount, amount, isPhase1Claimed, latestClaimDay

    function initiateWhitelist() external;

    function addBeneficiary(address user, uint256 amount) external;

    function deleteBeneficiary(address user) external returns (uint256);

    function releaseClaimable(address user) external returns (uint256);
}

interface ILockable {
    function beneficiary() external view returns (address);

    function changeTalaxAddress(address talax) external;

    function startLockedWallet() external view returns (uint256);

    function initiateLockedWallet() external;

    function releaseClaimable(uint256[51] memory amount)
        external
        returns (uint256);
}
