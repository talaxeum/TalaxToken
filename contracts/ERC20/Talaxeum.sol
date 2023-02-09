// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Talaxeum is ERC20, ERC20Burnable, Ownable {
    uint256 public taxRate = 100; // basis points

    address public advisor = address(0);
    address public platform = address(0);

    constructor() ERC20("Talaxeum", "TALAX") {
        _mint(_msgSender(), 21 * 1e9 * 10 ** decimals());
    }

    event ChangeTaxPercentage(uint256 tax);
    event ChangeAdvisorAddress(address indexed advisor);
    event ChangePlatformAddress(address indexed platform);

    fallback() external payable {}

    receive() external payable {}

    function publicSale() public pure returns (address) {
        return 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
    }

    function teamAndProjectCoordinator() public pure returns (address) {
        return 0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    }

    function marketing() public pure returns (address) {
        return 0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
    }

    function stakingReward() public pure returns (address) {
        return 0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    }

    function daoPool() public pure returns (address) {
        return 0x75837E79215250C45331b92c35B7Be506eD015AC;
    }

    function changeAdvisor(address newAddress) external onlyOwner {
        advisor = newAddress;
        emit ChangeAdvisorAddress(newAddress);
    }

    function changePlatform(address newAddress) external onlyOwner {
        platform = newAddress;
        emit ChangePlatformAddress(newAddress);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() external onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");

        require(sent == true, "Failed to send Ether");
    }

    function withdrawTalax() external onlyOwner {
        _transfer(address(this), owner(), balanceOf(address(this)));
    }

    function changeTax(uint256 tax) external onlyOwner {
        require(taxRate < 5, "Tax Fee maximum is 5%");
        taxRate = tax;
        emit ChangeTaxPercentage(tax);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

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

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();

        uint256 tax = (amount * taxRate) / 10_000;
        _spendAllowance(from, spender, amount + tax);

        _distributeTax(from, tax);
        _transfer(from, to, amount);
        return true;
    }

    // TODO: Possible to add mint functions for [escrowContracts]

    // The following functions are overrides required by Solidity.

    // Overridden to accommodate the tax fee
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        uint256 tax = (amount * taxRate) / 10_000;
        _approve(owner, spender, amount + tax);
        return true;
    }

    function _distributeTax(address from, uint256 tax) internal {
        _transfer(from, teamAndProjectCoordinator(), (tax * 2000) / 10_000);
        _transfer(from, address(this), (tax * 8000) / 10_000);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._transfer(from, to, amount);
    }
}
