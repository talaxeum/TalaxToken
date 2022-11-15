// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Data.sol";

contract Talaxeum is ERC20Burnable, Ownable {
    uint256 private taxPercent = 1;

    constructor() ERC20("Talaxeum", "TALAX") {
        _mint(_msgSender(), 21 * 1e9 * 10**decimals());
    }

    event ChangeTaxPercentage(uint256 tax);

    fallback() external payable {}

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() external {
        (bool sent, ) = team_and_project_coordinator_address.call{
            value: address(this).balance
        }("");

        require(sent, "Failed to send Ether");
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

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._afterTokenTransfer(from, to, amount);
    }
}
