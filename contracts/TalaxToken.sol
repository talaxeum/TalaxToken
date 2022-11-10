// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "./Data.sol";

contract Talaxeum is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    uint256 private taxPercent = 1;

    constructor() ERC20("Talaxeum", "TALAX") ERC20Permit("Talaxeum") {
        _mint(_msgSender(), 21 * 1e9 * 10**decimals());
        _mint(
            0x5D0ef486F7bAd84a71fa17D9627887eD82C46FF7,
            10 * 1e9 * decimals()
        );
    }

    event ChangeTaxPercentage(uint256 tax);

    fallback() external payable {}

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() external {
        uint256 thirdOfValue = address(this).balance / 3;

        (bool sent, ) = team_and_project_coordinator_address.call{
            value: thirdOfValue
        }("");

        require(sent == true, "Failed to send Ether");
    }

    function withdrawFunds(address token) external {
        SafeERC20.safeTransfer(
            IERC20(token),
            team_and_project_coordinator_address,
            IERC20(token).balanceOf(address(this))
        );
    }

    function changeTax(uint256 tax) external onlyOwner {
        taxPercent = tax;
        emit ChangeTaxPercentage(tax);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();

        uint256 tax = (amount * taxPercent) / 100;
        uint256 taxedAmount = amount - tax;

        uint256 teamFee = (tax * 2) / 10;
        uint256 liquidityFee = (tax * 8) / 10;

        _transfer(owner, team_and_project_coordinator_address, teamFee);
        _transfer(owner, liquidity_reserve_address, liquidityFee);
        _transfer(owner, to, taxedAmount);
        return true;
    }

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

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
