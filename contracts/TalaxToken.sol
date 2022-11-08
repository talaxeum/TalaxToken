// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Data.sol";
import "./Vesting.sol";
import "./Whitelist.sol";

contract TalaxToken is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 public daoProjectPool;
    uint8 public taxFee;

    bool public initializationStatus;

    /* ------------------------------------------ Addresses ----------------------------------------- */

    // Changeable address by owner
    address public time_lock_address;
    address public seed_sale_address;
    address public strategic_partner_address;

    /* ------------------------------------------ Vesting ------------------------------------------ */
    Vesting internal publicSaleVesting;
    Vesting internal teamAndProjectVesting;
    Vesting internal marketingVesting;
    Vesting internal stakingRewardVesting;
    Vesting internal liquidityReserveVesting;
    Vesting internal daoPoolVesting;

    /* ------------------------------------------ Whitelist ----------------------------------------- */
    Whitelist internal privateSaleWhitelist;
    Whitelist internal seedSaleWhitelist;
    Whitelist internal strategicPartnerWhitelist;

    struct Beneficiary {
        address user;
        uint256 amount;
    }

    constructor() ERC20("TALAXEUM", "TALAX") {
        _totalSupply = 21 * 1e9 * 1e18;
        _name = "TALAXEUM";
        _symbol = "TALAX";

        // later divided by 100 to make percentage
        taxFee = 1;

        /* --------------------------------------------- TGE -------------------------------------------- */
        _balances[public_sale_address] = 120656184 * 1e18;
        //! Private Sale
        //! Seed Sale
        _balances[liquidity_reserve_address] = 4200000 * 1e3 * 1e18;

        /* ------------------------------------------- Vesting ------------------------------------------ */
        publicSaleVesting = new Vesting(0, public_sale_address);
        teamAndProjectVesting = new Vesting(
            0,
            team_and_project_coordinator_address
        );
        marketingVesting = new Vesting(0, marketing_address);
        stakingRewardVesting = new Vesting(0, staking_reward_address);
        liquidityReserveVesting = new Vesting(0, liquidity_reserve_address);
        daoPoolVesting = new Vesting(0, dao_pool_address);

        /* ------------------------------------------ Whitelist ----------------------------------------- */
        privateSaleWhitelist = new Whitelist();
        seedSaleWhitelist = new Whitelist();
        strategicPartnerWhitelist = new Whitelist();

        // Vesting -> Public Sale, Team, Marketing, Staking Reward, Liquidity Reserve, Dao Pool
        // Whitelist -> Private Sale, Seed Sale, Strategic Partner
        _totalSupply -= 14114100 * 1e3 * 1e18;
    }

    fallback() external payable {
        // Add any ethers send to this address to team and project coordinators addresses
        (bool sent, ) = team_and_project_coordinator_address.call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {
        (bool sent, ) = team_and_project_coordinator_address.call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             EVENTS                                             */
    /* ---------------------------------------------------------------------------------------------- */

    event ChangeTax(address indexed who, uint256 amount);

    event ChangePrivatePlacementAddress(address indexed to);

    event ChangeStrategicPartnerAddress(
        address indexed from,
        address indexed to1
    );

    event AddBeneficiaries(
        address indexed from,
        Whitelist indexed whitelist,
        Beneficiary[] beneficiary
    );
    event DeleteBeneficiaries(
        address indexed from,
        Whitelist indexed whitelist,
        address[] beneficiary
    );

    event InitiateLockedWallet(address indexed user);
    event InitiateWhitelist(address indexed user);

    event TransferStakingReward(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event TransferDAOPool(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            MODIFIERS                                           */
    /* ---------------------------------------------------------------------------------------------- */
    function _isInitializationStarted() internal view {
        require(initializationStatus == true, "Not yet started");
    }

    modifier isInitialize() {
        _isInitializationStarted();
        _;
    }

    function _onlyWalletOwner(address walletOwner) internal view {
        require(_msgSender() == walletOwner, "Wallet owner only");
    }

    modifier onlyWalletOwner(address walletOwner) {
        _onlyWalletOwner(walletOwner);
        _;
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                       INTERNAL FUNCTIONS                                       */
    /* ---------------------------------------------------------------------------------------------- */

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

        uint256 tax = SafeMath.div(SafeMath.mul(amount, taxFee), 100);
        uint256 taxedAmount = amount - tax;

        uint256 teamFee = SafeMath.div(SafeMath.mul(taxedAmount, 2), 10);
        uint256 liquidityFee = SafeMath.div(SafeMath.mul(taxedAmount, 8), 10);

        _balances[team_and_project_coordinator_address] += teamFee;
        _balances[address(this)] += liquidityFee;

        _balances[to] += taxedAmount;
        emit Transfer(from, to, taxedAmount);
    }

    /**
     * @notice ERC20 FUNCTIONS
     */

    /**
     * @dev Returns the name of the token.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
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

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
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
    function _burn(address account, uint256 amount) internal override {
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

    /* ---------------------------------------------------------------------------------------------- */
    /*                                       External Functions                                       */
    /* ---------------------------------------------------------------------------------------------- */

    function changePrivatePlacementAddress(address _input) external onlyOwner {
        seed_sale_address = _input;
        emit ChangePrivatePlacementAddress(_input);
    }

    function changeStrategicPartnerAddress(address newAddress)
        external
        onlyOwner
    {
        strategic_partner_address = newAddress;
        emit ChangeStrategicPartnerAddress(msg.sender, newAddress);
    }

    function changeTaxFee(uint8 taxFee_) external onlyOwner {
        require(taxFee_ < 5, "Tax Fee maximum is 5%");
        taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }

    function initiateToken() external onlyOwner {
        require(initializationStatus == false, "Nothing to initialize");
        initializationStatus = true;

        publicSaleVesting.initiateLockedWallet();
        teamAndProjectVesting.initiateLockedWallet();
        marketingVesting.initiateLockedWallet();
        stakingRewardVesting.initiateLockedWallet();
        liquidityReserveVesting.initiateLockedWallet();
        daoPoolVesting.initiateLockedWallet();
        emit InitiateLockedWallet(_msgSender());

        privateSaleWhitelist.initiateWhitelist();
        seedSaleWhitelist.initiateWhitelist();
        strategicPartnerWhitelist.initiateWhitelist();
        emit InitiateWhitelist(_msgSender());
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Vesting                                            */
    /* ---------------------------------------------------------------------------------------------- */

    function unlockPublicSale()
        external
        isInitialize
        onlyWalletOwner(publicSaleVesting.beneficiary())
    {
        uint256 timeLockedAmount = publicSaleVesting.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    function unlockTeamAndProjectCoordinatorWallet()
        external
        isInitialize
        onlyWalletOwner(teamAndProjectVesting.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectVesting.releaseClaimable(
            teamAndProjectCoordinatorReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    function unlockMarketingWallet()
        external
        isInitialize
        onlyWalletOwner(marketingVesting.beneficiary())
    {
        uint256 timeLockedAmount = marketingVesting.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    function unlockStakingReward()
        external
        isInitialize
        onlyWalletOwner(stakingRewardVesting.beneficiary())
    {
        uint256 timeLockedAmount = stakingRewardVesting.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    function unlockLiquidityReserve()
        external
        isInitialize
        onlyWalletOwner(liquidityReserveVesting.beneficiary())
    {
        uint256 timeLockedAmount = liquidityReserveVesting.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    function unlockDaoPool()
        external
        isInitialize
        onlyWalletOwner(daoPoolVesting.beneficiary())
    {
        uint256 timeLockedAmount = daoPoolVesting.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] += timeLockedAmount;
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            Whitelist                                           */
    /* ---------------------------------------------------------------------------------------------- */

    // function addBeneficiary(address user, uint256 amount) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     require(amount > 0, "Cannot add beneficiary with 0 amount");
    //     privateSale -= amount;
    //     _addBeneficiary(user, amount);
    //     emit AddPrivateSale(msg.sender, user, amount);
    // }

    function _checkBeneficiaryAmount(uint256 amount)
        internal
        view
        isInitialize
    {
        require(amount != 0, "Amount cannot be zero");
    }

    function unsafeInc(uint256 x) internal pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function addBeneficiariesPrivateSale(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            _checkBeneficiaryAmount(benefs[i].amount);
            privateSaleWhitelist.addBeneficiary(
                benefs[i].user,
                benefs[i].amount
            );
        }
        emit AddBeneficiaries(msg.sender, privateSaleWhitelist, benefs);
    }

    function addBeneficiariesSeedSale(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            _checkBeneficiaryAmount(benefs[i].amount);
            seedSaleWhitelist.addBeneficiary(benefs[i].user, benefs[i].amount);
        }
        emit AddBeneficiaries(msg.sender, seedSaleWhitelist, benefs);
    }

    function addBeneficiariesStrategicPartner(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            _checkBeneficiaryAmount(benefs[i].amount);
            strategicPartnerWhitelist.addBeneficiary(
                benefs[i].user,
                benefs[i].amount
            );
        }
        emit AddBeneficiaries(msg.sender, strategicPartnerWhitelist, benefs);
    }

    // function deleteBeneficiary(address user) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     uint256 amount = _deleteBeneficiary(user);
    //     privateSale += amount;
    //     emit DeletePrivateSale(msg.sender, user);
    // }

    function deleteBeneficiariesPrivateSale(address[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            privateSaleWhitelist.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiaries(msg.sender, privateSaleWhitelist, benefs);
    }

    function deleteBeneficiariesSeedSale(address[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            seedSaleWhitelist.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiaries(msg.sender, seedSaleWhitelist, benefs);
    }

    function deleteBeneficiariesStrategicPartner(address[] calldata benefs)
        external
        onlyOwner
        isInitialize
    {
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            strategicPartnerWhitelist.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiaries(msg.sender, strategicPartnerWhitelist, benefs);
    }

    function claimPrivateSale() external isInitialize {
        uint256 whitelistAmount = privateSaleWhitelist.releaseClaimable(
            _msgSender()
        );
        _balances[_msgSender()] += whitelistAmount;
    }

    function claimSeedSale() external isInitialize {
        uint256 whitelistAmount = seedSaleWhitelist.releaseClaimable(
            _msgSender()
        );
        _balances[_msgSender()] += whitelistAmount;
    }

    function claimStrategicPartner() external isInitialize {
        uint256 whitelistAmount = strategicPartnerWhitelist.releaseClaimable(
            _msgSender()
        );
        _balances[_msgSender()] += whitelistAmount;
    }
}
