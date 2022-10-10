// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./governance/ERC20Votes.sol";

import "./Data.sol";
import "./Interfaces.sol";
import "./VestingWallet.sol";

/**
 * @notice Custom error
 */
error Tax__maxFivePercent();
error Transfer__failedToSendEther();

contract TalaxTokenDeprecated is
    ERC20,
    ERC20Burnable,
    Ownable,
    ERC20Permit,
    ERC20Votes
{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /* ------------------------------------- Additional Settings ------------------------------------ */
    mapping(uint256 => uint256) internal _stakingPackage;
    uint256 public stakingReward;
    uint256 public daoProjectPool;
    uint8 public taxFee;

    bool public airdropStatus;
    bool public initializationStatus;

    uint256 public vesting_start;
    /* ------------------------------------------ Addresses ----------------------------------------- */
    // ! Changeable address by owner
    address public governance_address;

    /*
     * Notes
     * S     = Staking
     * PP    = Private Placement
     * PS    = Private Sale
     * M     = Marketing
     * SP    = Strategic Partner
     * TPC   = Team and Project Coordinator
     */

    VestingWallet public M_contract_1;
    VestingWallet public M_contract_2;
    VestingWallet public M_contract_3;
    VestingWallet public TPC_contract_1;
    VestingWallet public TPC_contract_2;
    VestingWallet public TPC_contract_3;

    /* ------------------------------------------- EVENTS ------------------------------------------- */
    event ChangeTax(address indexed who, uint256 amount);

    event ChangeStrategicPartnerAddress(
        address from,
        address indexed to1,
        address indexed to2,
        address indexed to3
    );

    constructor() ERC20("Talaxeum", "TALAX") ERC20Permit("Talaxeum") {
        _totalSupply = 21 * 1e9 * 1e18;

        // later divided by 100 to make percentage
        taxFee = 1;

        /*
         * 1.     Public Sale                   - // Vesting
         * 2.     Private Placement             - // Whitelist (no pattern percentage)
         * 3.     Private Sale                  - // Whitelist
         * 4.     Strategic Partner & Advisory  - // Whitelist
         * 5.     Team                          - // Vesting
         * 6.     Marketing                     - // Vesting
         * 7.     CEX Listing                   - // Vesting
         * 8.     Staking Reward                - // Vesting
         * 9.     Liquidity Reserve             - // Vesting
         * 10.    DAO Project Launcher Pool     - // Vesting
         */

        /* --------------------------------------------- TGE -------------------------------------------- */
        _balances[public_sale_address] = 120656184 * 1e18;
        _balances[marketing_address_1] = 50400000 * 1e18;
        // _balances[msg.sender] = 10000 * 1e18; // for testing and staging
        // _balances[address(this)] = 10000 * 1e18; // for testing and staging
        /* ---------------------------------------------- - --------------------------------------------- */

        // Public Sale, CEX Listing - EOA Type Balance
        // Private Sale - Multilock.sol
        // Private Placement, Strategic Partner & Advisory, Team and Project Contributor, Marketing - Locked Wallet Type Balance
        // Staking Reward, Liquidity Reserve, DAO Project Pool - Smart Contract Balance
        // _totalSupply = _totalSupply.sub(
        //     14114100 * 1e3 * 1e18,
        //     "Insufficient Total Supply"
        // );

        // TODO: Transfer Ownership to Governance Contract address
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }

        uint256 tax = (amount * taxFee) / 100;
        uint256 taxedAmount = amount - tax;

        uint256 teamFee = (tax * 2) / 10;
        uint256 liquidityFee = (tax * 8) / 10;

        _addThirdOfValue(teamFee);
        _balances[address(this)] = _balances[address(this)] + liquidityFee;

        _balances[to] = _balances[to] + taxedAmount;
        emit Transfer(from, to, taxedAmount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                     END OF TOKEN FUNCTIONS                                     */
    /* ---------------------------------------------------------------------------------------------- */

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

    /* --------------------------------------- ADDED FUNCTIONS -------------------------------------- */

    function _addThirdOfValue(uint256 amount_) internal {
        uint256 thirdOfValue = amount_ / 3;
        _balances[team_and_project_coordinator_address_1] =
            _balances[team_and_project_coordinator_address_1] +
            thirdOfValue;

        _balances[team_and_project_coordinator_address_2] =
            _balances[team_and_project_coordinator_address_2] +
            thirdOfValue;

        _balances[team_and_project_coordinator_address_3] =
            _balances[team_and_project_coordinator_address_3] +
            thirdOfValue;
    }

    function changeTaxFee(uint8 taxFee_) external onlyOwner {
        if (taxFee_ > 5) {
            revert Tax__maxFivePercent();
        }
        taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }
}
