// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Stakable.sol";
import "./Lockable.sol";
import "./Multilockable.sol";

contract TalaxToken is ERC20, ERC20Burnable, Ownable, Stakable, Multilockable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(uint256 => uint256) internal _stakingPackage;
    uint256 public stakingReward;
    uint256 public privateSale;
    uint256 public airdropSince;
    bool public airdropStatus;
    bool public lockedWalletStatus;
    bool public privateSaleStatus;

    uint16 public _taxFee;

    /* ------------------------------------------ Addresses ----------------------------------------- */

    address private timelockController;

    /**
     * Local (in this smart contract)
     * address staking_reward_address;
     * address liquidity_reserve_address;
     */

    address public constant public_sale_address =
        0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
    address public constant private_placement_address =
        0x07A20dc6722563783e44BA8EDCA08c774621125E;
    address public constant dev_pool_address_1 =
        0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
    address public constant dev_pool_address_2 =
        0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
    address public constant dev_pool_address_3 =
        0x126974fa373267d86fAB6d6871Afe62ccB68e810;
    address public constant strategic_partner_address_1 =
        0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    address public constant strategic_partner_address_2 =
        0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    address public constant strategic_partner_address_3 =
        0xAeB26fB84d0E2b3B353Cd50f0A29FD40C916d2Ab;
    address public constant team_and_project_coordinator_address_1 =
        0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
    address public constant team_and_project_coordinator_address_2 =
        0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
    address public constant team_and_project_coordinator_address_3 =
        0x97620dEAdC98bC8173303686037ce7B986CF53C3;

    /* ------------------------------------------ Lockable ------------------------------------------ */

    Lockable private privatePlacementLockedWallet;
    Lockable private devPoolLockedWallet_1;
    Lockable private devPoolLockedWallet_2;
    Lockable private devPoolLockedWallet_3;
    Lockable private strategicPartnerLockedWallet_1;
    Lockable private strategicPartnerLockedWallet_2;
    Lockable private strategicPartnerLockedWallet_3;
    Lockable private teamAndProjectCoordinatorLockedWallet_1;
    Lockable private teamAndProjectCoordinatorLockedWallet_2;
    Lockable private teamAndProjectCoordinatorLockedWallet_3;

    struct Beneficiary {
        address user;
        uint256 amount;
    }

    constructor() ERC20("TALAXEUM", "TALAX") {
        _totalSupply = 210 * 1e6 * 1e18;
        _name = "TALAXEUM";
        _symbol = "TALAX";

        // later divided by 100 to make percentage
        _taxFee = 1;

        airdropStatus = false;

        // Staking APY in percentage
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[360 days] = 8;

        /**
         * Amount Initialization
         */

        // _balances[address(this)] = 52500 * 1e3 * 1e18;
        _balances[msg.sender] = 52500 * 1e3 * 1e18;
        stakingReward = 17514 * 1e3 * 1e18;

        // Public Sale
        _balances[public_sale_address] = 2310 * 1e3 * 1e18;

        // Private Sale
        // privateSaleLockedWallet = new Multilockable(14679 * 1e3 * 1e18);
        privateSale = 14679 * 1e3 * 1e18;

        /**
         * Locked Wallet Initialization
         */

        privatePlacementLockedWallet = new Lockable(
            6993 * 1e3 * 1e18,
            private_placement_address
        );

        devPoolLockedWallet_1 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_1
        );
        devPoolLockedWallet_2 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_2
        );
        devPoolLockedWallet_3 = new Lockable(
            24668 * 1e3 * 1e18,
            dev_pool_address_3
        );

        strategicPartnerLockedWallet_1 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_1
        );
        strategicPartnerLockedWallet_2 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_2
        );
        strategicPartnerLockedWallet_3 = new Lockable(
            3500 * 1e3 * 1e18,
            strategic_partner_address_3
        );

        teamAndProjectCoordinatorLockedWallet_1 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_1
        );
        teamAndProjectCoordinatorLockedWallet_2 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_2
        );
        teamAndProjectCoordinatorLockedWallet_3 = new Lockable(
            10500 * 1e3 * 1e18,
            team_and_project_coordinator_address_3
        );

        //Public Sale, Private Sale, Private Placement, Staking Reward
        // Dev Pool, Strategic Partner, Team and Project Coordinator
        _totalSupply = _totalSupply.sub(
            157500 * 1e3 * 1e18,
            "Insufficient Total Supply"
        );
    }

    fallback() external payable {
        // Add any ethers send to this address to team and project coordinators addresses
        _addThirdOfValue(msg.value);
    }

    receive() external payable {
        _addThirdOfValue(msg.value);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             EVENTS                                             */
    /* ---------------------------------------------------------------------------------------------- */

    event ChangeTax(address indexed who, uint256 amount);
    event ChangeAirdropStatus(address indexed who, bool status);
    event ChangePenaltyFee(address indexed from, uint256 amount);
    event ChangeAirdropPercentage(address indexed from, uint256 amount);

    event AddPrivateSale(
        address indexed from,
        address indexed who,
        uint256 amount
    );
    event DeletePrivateSale(address indexed from, address indexed who);

    event InitiatePrivateSale(address indexed from);
    event InitiateLockedWallet(address indexed from);

    event TransferStakingReward(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            MODIFIERS                                           */
    /* ---------------------------------------------------------------------------------------------- */

    modifier lockedWalletInitiated() {
        require(lockedWalletStatus == true, "Locked Wallet not yet started");
        _;
    }

    modifier onlyWalletOwner(address walletOwner) {
        require(_msgSender() == walletOwner, "Wallet owner only");
        _;
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                       INTERNAL FUNCTIONS                                       */
    /* ---------------------------------------------------------------------------------------------- */

    /**
     * @dev this is the release rate for partial token release
     */
    function privatePlacementReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(43706, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            SafeMath.mul(524475, 1e18),
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
        ];
    }

    function devPoolReleaseAmount() internal pure returns (uint256[55] memory) {
        return [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(154175, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            SafeMath.mul(650961, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function strategicPartnerReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(21875, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            SafeMath.mul(87500, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function teamAndProjectCoordinatorReleaseAmount()
        internal
        pure
        returns (uint256[55] memory)
    {
        return [
            SafeMath.mul(105000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(315000, 1e18),
            0,
            0,
            0,
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            SafeMath.mul(262500, 1e18),
            0,
            0,
            0,
            0
        ];
    }

    function _addThirdOfValue(uint256 amount_) internal {
        uint256 thirdOfValue = SafeMath.div(amount_, 3);
        _balances[team_and_project_coordinator_address_1] = _balances[
            team_and_project_coordinator_address_1
        ].add(thirdOfValue);

        _balances[team_and_project_coordinator_address_2] = _balances[
            team_and_project_coordinator_address_2
        ].add(thirdOfValue);

        _balances[team_and_project_coordinator_address_3] = _balances[
            team_and_project_coordinator_address_3
        ].add(thirdOfValue);
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

        uint256 tax = SafeMath.div(SafeMath.mul(amount, _taxFee), 100);
        uint256 taxedAmount = SafeMath.sub(amount, tax);

        uint256 teamFee = SafeMath.div(SafeMath.mul(taxedAmount, 2), 10);
        uint256 liquidityFee = SafeMath.div(SafeMath.mul(taxedAmount, 8), 10);

        _addThirdOfValue(teamFee);
        _balances[address(this)] = _balances[address(this)].add(liquidityFee);

        _balances[to] = _balances[to].add(taxedAmount);
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

    /**
     * @notice EXTERNAL FUNCTIONS
     */

    /**
     * @dev Creates 'amount_' of token into stakingReward and liduidityReserve
     * @dev Deletes 'amount_' of token from stakingReward
     * @dev Change '_taxFee' with 'taxFee_'
     */

    function _mintStakingReward(uint256 amount_) internal {
        stakingReward = stakingReward.add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit TransferStakingReward(address(0), address(this), amount_);
    }

    function mintStakingReward(uint256 amount_) public onlyOwner {
        _mintStakingReward(amount_);
    }

    function mintLiquidityReserve(uint256 amount_) public onlyOwner {
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), address(this), amount_);
    }

    function burnStakingReward(uint256 amount_) external onlyOwner {
        stakingReward = stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit TransferStakingReward(address(this), address(0), amount_);
    }

    function burnLiquidityReserve(uint256 amount_) external onlyOwner {
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(address(this), address(0), amount_);
    }

    function changeTaxFee(uint16 taxFee_) external onlyOwner {
        require(taxFee_ < 5, "Tax Fee maximum is 5%");
        _taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }

    function changePenaltyFee(uint256 penaltyFee_) external onlyOwner {
        _changePenaltyFee(penaltyFee_);
        emit ChangePenaltyFee(_msgSender(), penaltyFee_);
    }

    function changeAirdropPercentage(uint256 airdrop_) external onlyOwner {
        _changeAirdropPercentage(airdrop_);
        emit ChangeAirdropPercentage(_msgSender(), airdrop_);
    }

    /* ------------------------ Stake function with burn function ------------------------ */
    function stake(uint256 _amount, uint256 _stakePeriod) external {
        // Make sure staker actually is good for it
        require(
            _stakePeriod == 30 days ||
                _stakePeriod == 90 days ||
                _stakePeriod == 180 days ||
                _stakePeriod == 365 days,
            "Staking option doesnt exist"
        );

        _stake(
            msg.sender,
            _amount,
            _stakePeriod,
            _stakingPackage[_stakePeriod]
        );
        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);
        // Stake amount goes to liquidity reserve
        _balances[address(this)] = _balances[address(this)].add(_amount);
    }

    /* ---- withdrawStake is used to withdraw stakes from the account holder ---- */
    function withdrawStake(uint256 amount) external {
        (uint256 amount_, uint256 reward_) = _withdrawStake(msg.sender, amount);
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintStakingReward(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount);
        stakingReward = stakingReward.sub(reward_);
        _totalSupply = _totalSupply.add(amount_ + reward_);
        _balances[_msgSender()] = _balances[_msgSender()].add(
            amount_ + reward_
        );
    }

    function claimAirdrop() external {
        require(airdropStatus == true, "Airdrop not yet started");
        uint256 airdrop = _claimAirdrop(_msgSender());
        _balances[address(this)] = _balances[address(this)].sub(airdrop);
        _balances[_msgSender()] = _balances[_msgSender()].add(airdrop);
    }

    function airdropWeek() external view {
        require(airdropStatus == true, "Airdrop not yet started");
        return (block.timestamp - airdropSince) / 7 days;
    }

    /* -------------------------------------------------------------------------- */
    /*                                Locked Wallet                               */
    /* -------------------------------------------------------------------------- */
    function initiateLockedWalletprivateSale_Airdrop() external onlyOwner {
        require(
            lockedWalletStatus == false && privateSaleStatus == false,
            "Nothing to initialize"
        );
        lockedWalletStatus = true;
        privatePlacementLockedWallet.initiateLockedWallet();
        devPoolLockedWallet_1.initiateLockedWallet();
        devPoolLockedWallet_2.initiateLockedWallet();
        devPoolLockedWallet_3.initiateLockedWallet();
        strategicPartnerLockedWallet_1.initiateLockedWallet();
        strategicPartnerLockedWallet_2.initiateLockedWallet();
        strategicPartnerLockedWallet_3.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_1.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_2.initiateLockedWallet();
        teamAndProjectCoordinatorLockedWallet_3.initiateLockedWallet();
        emit InitiateLockedWallet(_msgSender());

        privateSaleStatus = true;
        _initiatePrivateSale();
        emit InitiatePrivateSale(_msgSender());

        airdropStatus = true;
        airdropSince = block.timestamp;
        emit ChangeAirdropStatus(_msgSender(), status_);
    }

    /* ---------------------------- Private Placement --------------------------- */
    function unlockPrivatePlacementWallet()
        external
        lockedWalletInitiated
        onlyWalletOwner(privatePlacementLockedWallet.beneficiary())
    {
        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------- Dev Pool -------------------------------- */
    function unlockDevPoolWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_1.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_2.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(devPoolLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = devPoolLockedWallet_3.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------------- Strategic Partner --------------------------- */
    function unlockStrategicPartnerWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_1
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_2
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(strategicPartnerLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = strategicPartnerLockedWallet_3
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------- Team and Project Coordinator ---------------------- */
    function unlockTeamAndProjectCoordinatorWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(teamAndProjectCoordinatorLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Private Sale                                */
    /* -------------------------------------------------------------------------- */

    // function addBeneficiary(address user, uint256 amount) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     require(amount > 0, "Cannot add beneficiary with 0 amount");
    //     privateSale -= amount;
    //     _addBeneficiary(user, amount);
    //     emit AddPrivateSale(msg.sender, user, amount);
    // }

    function addMultipleBeneficiary(Beneficiary[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i++) {
            require(benefs[i].amount != 0, "Amount cannot be zero");
            privateSale = privateSale.sub(benefs[i].amount);
            _addBeneficiary(benefs[i].user, benefs[i].amount);
            emit AddPrivateSale(msg.sender, benefs[i].user, benefs[i].amount);
        }
    }

    // function deleteBeneficiary(address user) external onlyOwner {
    //     require(privateSaleStatus == true, "Private Sale not yet started");
    //     uint256 amount = _deleteBeneficiary(user);
    //     privateSale += amount;
    //     emit DeletePrivateSale(msg.sender, user);
    // }

    function deleteMultipleBeneficiary(address[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i++) {
            uint256 amount = _deleteBeneficiary(benefs[i]);
            privateSale = privateSale.add(amount);
            emit DeletePrivateSale(msg.sender, benefs[i]);
        }
    }

    function claimPrivateSale() external {
        uint256 privateSale = _releaseClaimable(_msgSender());
        _balances[_msgSender()] = _balances[_msgSender()].add(privateSale);
    }
}
