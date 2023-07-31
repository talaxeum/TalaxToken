// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice This error comes up when withdrawing eths from this contract failed
error FailedToSendEther();
/// @notice This error comes up when changing the tax does not qualify the requirement
/// @param tax This is the value of maximum tax that can be set which is 5%
error TaxLimitError(bytes32 tax);

/// @title Talaxeum ERC20 Contract
/// @author Emveep
/// @notice This contract handles all of Talaxeum ERC20 transaction and funcionality
contract Talaxeum is ERC20, ERC20Burnable, Ownable {
    /// @notice This variable handle the taxRate when transfer occurs
    uint256 public taxRate = 100; // basis points

    /// @notice This address is for advisor
    /// @dev This address accepts x amount of fee
    address public advisor = address(0);
    /// @notice This address is for Talaxeum Platform
    /// @dev This address accepts x amount of fee
    address public platform = address(0);

    /// @notice This address is used for public sale purposes, later will receive x amount of token
    /// @dev Change address function is not yet implemented
    address constant public_sale = 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
    /// @notice This address is used for team and project coordinator, later will receive x amount of token
    /// @dev Change address function is not yet implemented
    address constant team_and_project_coordinator =
        0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    /// @notice This address is used for marketing team, later will receive x amount of token
    /// @dev Change address function is not yet implemented
    address constant marketing = 0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
    /// @notice This address is used for storing staking rewards, later will receive x amount of token
    /// @dev Change address function is not yet implemented
    address constant staking_reward =
        0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    /// @notice This address is used for liquidity reserves, later will receive x amount of token
    /// @dev Change address function is not yet implemented
    address constant liquidity_reserve =
        0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
    /// @notice This address is used for dao pool, later will receive x amount of token, see whitepaper for detailed information
    /// @dev Change address function is not yet implemented
    address constant dao_pool = 0x75837E79215250C45331b92c35B7Be506eD015AC;

    // address constant team_and_project_coordinator_3 = 0x97620dEAdC98bC8173303686037ce7B986CF53C3;

    constructor() ERC20("Talaxeum", "TALAX") {
        _mint(_msgSender(), 21 * 1e9 * 10 ** decimals());
    }

    /// @notice This event is emitted when changeTax() is called
    /// @param tax This is the tax amount in basis point format
    event ChangeTaxPercentage(uint256 tax);
    /// @notice This event is emitted when changeAdvisor() is called
    /// @param advisor This is the new advisor's address
    event ChangeAdvisorAddress(address indexed advisor);
    /// @notice This event is emitted when changePlatform() is called
    /// @param platform This is the new platform's address
    event ChangePlatformAddress(address indexed platform);

    fallback() external payable {}

    receive() external payable {}

    /// @notice This function is used to change the advisor address
    /// @param newAddress This is the address of the new advisor
    function changeAdvisor(address newAddress) external onlyOwner {
        advisor = newAddress;
        emit ChangeAdvisorAddress(newAddress);
    }

    /// @notice This function is used to change the platform address
    /// @param newAddress This is the address of the new platform
    function changePlatform(address newAddress) external onlyOwner {
        platform = newAddress;
        emit ChangePlatformAddress(newAddress);
    }

    /// @notice This function is used to get the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @notice This function is used to withdraw eth of this contract to the owner
    function withdrawFunds() external onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");

        if (sent != true) revert FailedToSendEther();
    }

    /// @notice This function is used to withdraw talax token of this contract to the owner
    function withdrawTalax() external onlyOwner {
        _transfer(address(this), owner(), balanceOf(address(this)));
    }

    /// @notice This function is used to change the tax for transfer transaction
    /// @param tax This is the amount of tax that want to be implemented
    function changeTax(uint256 tax) external onlyOwner {
        if (taxRate > 500) revert TaxLimitError("5%");
        taxRate = tax;
        emit ChangeTaxPercentage(tax);
    }

    /// @notice This function is used to mint talax token
    /// @param to This is the target address of the mint function
    /// @param amount This is the amount of mint
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice This function transfer talax token from the caller to the target address
    /// @param to This is the target address
    /// @param amount This is the amount of transfer
    /// @return Return the status of the transfer
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();

        uint256 tax = (amount * taxRate) / 10_000;
        uint256 taxedAmount = amount - tax;

        _distributeTax(spender, tax);
        _transfer(spender, to, taxedAmount);
        return true;
    }

    /// @notice This function transfer talax token from the source address to the target address, called by msgsender
    /// @param from This is the source address
    /// @param to This is the target address
    /// @param amount This is the amount of transfer
    /// @return Return the status of the transfer
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();

        uint256 tax = (amount * taxRate) / 10_000;
        _spendAllowance(from, spender, amount + tax);

        _distributeTax(from, tax);
        _transfer(from, to, amount);
        return true;
    }

    // The following functions are overrides required by Solidity.

    /// @notice This function is used to approve a certain amount of talax token to be managed by the spender
    /// @dev Overridden to accommodate the tax fee
    /// @param spender This is the spender
    /// @param amount This is the amount that managed by the spender
    /// @return Return the status of the transaction
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        uint256 tax = (amount * taxRate) / 10_000;
        _approve(owner, spender, amount + tax);
        return true;
    }

    /// @notice This is a custom function to transfer the tax to the team_and_project_coordinator address and this contract
    /// @param from This is the source address
    /// @param tax This is how much tax that gonna be transferred
    function _distributeTax(address from, uint256 tax) internal {
        _transfer(from, team_and_project_coordinator, (tax * 2000) / 10_000);
        _transfer(from, address(this), (tax * 8000) / 10_000);
    }

    /// @notice This is the transfer function that needed to be overriden
    /// @param from This is the source address
    /// @param to This is the target address
    /// @param amount This is the amount of the transfer
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._transfer(from, to, amount);
    }
}
