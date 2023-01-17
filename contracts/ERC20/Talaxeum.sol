// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Talaxeum is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    uint256 public taxRate = 100; // basis points

    constructor() ERC20("Talaxeum", "TALAX") ERC20Permit("Talaxeum") {
        _mint(_msgSender(), 21 * 1e9 * 10 ** decimals());
    }

    event ChangeTaxPercentage(uint256 tax);

    fallback() external payable {}

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() external onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");

        require(sent == true, "Failed to send Ether");
    }

    function withdrawFunds(address token) external onlyOwner {
        SafeERC20.safeTransfer(
            IERC20(token),
            owner(),
            IERC20(token).balanceOf(address(this))
        );
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
        address owner = _msgSender();

        uint256 tax = (amount * taxRate) / 10_000;
        uint256 taxedAmount = amount - tax;

        _transfer(owner, address(this), tax);
        _transfer(owner, to, taxedAmount);
        return true;
    }

    // TODO: Possible to add mint functions for [escrowContracts]

    // The following functions are overrides required by Solidity.

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._transfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
