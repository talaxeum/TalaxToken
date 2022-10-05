// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "./Data.sol";

error Transfer__failedToSendEther();

contract TalaxToken is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    uint256 private taxPercent = 1;

    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    fallback() external payable {}

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFunds() external onlyOwner {
        uint256 thirdOfValue = address(this).balance / 3;

        (bool sent, bytes memory data) = team_and_project_coordinator_address_1
            .call{value: thirdOfValue}("");

        (
            bool sent1,
            bytes memory data1
        ) = team_and_project_coordinator_address_2.call{value: thirdOfValue}(
                ""
            );

        (
            bool sent2,
            bytes memory data2
        ) = team_and_project_coordinator_address_3.call{value: thirdOfValue}(
                ""
            );

        if (sent && sent1 && sent2 == true) {
            revert Transfer__failedToSendEther();
        }
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

        uint256 tax = amount * taxPercent;
        uint256 taxedAmount = amount - tax;

        uint256 teamFee = (tax * 2) / 10;
        uint256 liquidityFee = (tax * 8) / 10;

        _transfer(owner, team_and_project_coordinator_address_1, (teamFee / 3));
        _transfer(owner, team_and_project_coordinator_address_2, (teamFee / 3));
        _transfer(owner, team_and_project_coordinator_address_3, (teamFee / 3));
        _transfer(owner, liquidity_reserve, liquidityFee);
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
