// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./IBEP20.sol";
import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

import "./Stakable.sol";
import "./Lockable.sol";
import "./Multilockable.sol";

contract TalaxToken is IBEP20, Ownable, Stakable, Multilockable {
    //BEP20 TOKEN PARAMETERES
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    mapping(uint256 => uint256) internal _stakingPackage;
    uint256 public _stakingReward;
    uint256 public _devPool;
    uint256 public _privateSale;
    bool public _airdropStatus;
    bool public lockedWalletStatus;
    bool public privateSaleStatus;

    uint16 public _taxFee;

    /* ------------------------------------------ Addresses ----------------------------------------- */
    /**
     * Local (in this smart contract)
     * staking_reward_address;
     * liquidity_reserve_address;
     * dev_pool_address;
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
    // address private team_and_project_coordinator_address_1 = 0x84435c6FD8de0E75D6b3dC108F4345344a91a268; //for testing only
    address public constant team_and_project_coordinator_address_1 =
        0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
    address public constant team_and_project_coordinator_address_2 =
        0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
    address public constant team_and_project_coordinator_address_3 =
        0x97620dEAdC98bC8173303686037ce7B986CF53C3;

    Lockable private privatePlacementLockedWallet;
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

    constructor() {
        _name = "TALAXEUM";
        _symbol = "TALAX";
        _decimals = 18;
        _totalSupply = 210 * 1e6 * 1e18;
        _balances[msg.sender] = _balances[msg.sender].add(_totalSupply);

        // later divided by 100 to make percentage
        _taxFee = 1;

        _airdropStatus = false;

        // Staking APY in percentage
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[360 days] = 8;

        /**
         * Amount Initialization
         */

        _balances[address(this)] = 52500 * 1e3 * 1e18;
        _stakingReward = 17514 * 1e3 * 1e18;
        _devPool = 74004 * 1e3 * 1e18;

        // Public Sale
        _balances[public_sale_address] = 2310 * 1e3 * 1e18;

        // Private Sale
        // privateSaleLockedWallet = new Multilockable(14679 * 1e3 * 1e18);
        _privateSale = 14679 * 1e3 * 1e18;

        /**
         * Locked Wallet Initialization
         */

        privatePlacementLockedWallet = new Lockable(
            6993 * 1e3 * 1e18,
            private_placement_address
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

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            MODIFIERS                                           */
    /* ---------------------------------------------------------------------------------------------- */

    modifier lockedWalletInitiated() {
        require(lockedWalletStatus == true, "Locked Wallet not yet started");
        _;
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            ACCESSORS                                           */
    /* ---------------------------------------------------------------------------------------------- */

    /**
     * @dev See address of this smart contract.
     */
    function thisAddress() external view returns (address) {
        return address(this);
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

    /**
     * @notice TOKEN FUNCTIONS
     */

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
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
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
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
    ) internal {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient Balance");

        uint256 tax = SafeMath.div(SafeMath.mul(amount, _taxFee), 100);
        uint256 taxedAmount = SafeMath.sub(amount, tax);

        uint256 teamFeeOfThird = SafeMath.div(
            SafeMath.div(SafeMath.mul(taxedAmount, 2), 10),
            3
        );

        uint256 liquidityFee = SafeMath.div(SafeMath.mul(taxedAmount, 8), 10);

        _balances[team_and_project_coordinator_address_1] = _balances[
            team_and_project_coordinator_address_1
        ].add(teamFeeOfThird);

        _balances[team_and_project_coordinator_address_2] = _balances[
            team_and_project_coordinator_address_2
        ].add(teamFeeOfThird);

        _balances[team_and_project_coordinator_address_3] = _balances[
            team_and_project_coordinator_address_3
        ].add(teamFeeOfThird);

        _balances[address(this)] = _balances[address(this)].add(liquidityFee);

        _balances[from] = _balances[from].sub(amount, "Insufficient Balance");
        _balances[to] = _balances[to].add(taxedAmount);
        emit Transfer(from, to, taxedAmount);
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

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }

    /**
     * @notice EXTERNAL FUNCTIONS
     */

    function transferDevPool(address to_, uint256 amount_) external onlyOwner {
        require(amount_ != 0, "Invalid amount");
        require(amount_ < _devPool, "Insufficient supply");
        require(to_ != address(0), "Invalid address");
        _balances[to_] += amount_;
        _devPool -= amount_;
    }

    /**
     * @dev Creates 'amount_' of token into _stakingReward and liduidityReserve
     * @dev Deletes 'amount_' of token from _stakingReward
     * @dev Change '_taxFee' with 'taxFee_'
     */

    function mintStakingReward(uint256 amount_) external onlyOwner {
        require(amount_ != 0, "Amount mint cannot be 0");
        _stakingReward = _stakingReward.add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), address(this), amount_);
    }

    function mintLiquidityReserve(uint256 amount_) public onlyOwner {
        require(amount_ > 0, "Amount mint cannot be 0");
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), address(this), amount_);
    }

    function burnStakingReward(uint256 amount_) external onlyOwner {
        require(
            amount_ < _stakingReward,
            "Amount burnt larger than Staking Reward"
        );
        _stakingReward = _stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(address(this), address(0), amount_);
    }

    function burnLiquidityReserve(uint256 amount_) external onlyOwner {
        require(
            amount_ < _balances[address(this)],
            "Amount burnt larger than balance"
        );
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(address(this), address(0), amount_);
    }

    function changeTaxFee(uint16 taxFee_) external onlyOwner {
        require(taxFee_ < 5, "Tax Fee maximum is 5%");
        _taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }

    function changeAirdropStatus(bool status_) external onlyOwner {
        _airdropStatus = status_;
        emit ChangeAirdropStatus(_msgSender(), status_);
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
        require(_amount < _balances[_msgSender()], "Insufficient Balance");

        _stake(_amount, _stakePeriod, _stakingPackage[_stakePeriod]);
        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);
        // Stake amount goes to liquidity reserve
        _balances[address(this)] = _balances[address(this)].add(_amount);
    }

    /* ---- withdrawStake is used to withdraw stakes from the account holder ---- */
    function withdrawStake(uint256 amount, uint256 stake_index) external {
        (uint256 amount_, uint256 reward_) = _withdrawStake(
            amount,
            stake_index
        );
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintLiquidityReserve(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _balances[address(this)] = _balances[address(this)].sub(reward_);
        _totalSupply += amount_ + reward_;
        _balances[_msgSender()] += amount_ + reward_;
    }

    function withdrawAllStake(uint256 stake_index) external {
        (uint256 amount_, uint256 reward_) = _withdrawAllStake(stake_index);
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintLiquidityReserve(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _balances[address(this)] = _balances[address(this)].sub(reward_);
        _totalSupply += amount_ + reward_;
        _balances[_msgSender()] += amount_ + reward_;
    }

    function claimAirdrop() external {
        require(_airdropStatus == true, "Airdrop not yet started");
        uint256 airdrop = _claimAirdrop(_msgSender());
        _balances[address(this)] = _balances[address(this)].sub(airdrop);
        _balances[_msgSender()] = _balances[_msgSender()].add(airdrop);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Locked Wallet                               */
    /* -------------------------------------------------------------------------- */
    function initiateLockedWallet_PrivateSale() external onlyOwner {
        require(
            lockedWalletStatus == false && privateSaleStatus == false,
            "Nothing to initialize"
        );
        lockedWalletStatus = true;
        privatePlacementLockedWallet.initiateLockedWallet();
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
    }

    /* ---------------------------- Private Placement --------------------------- */
    function unlockPrivatePlacementWallet() external lockedWalletInitiated {
        require(
            _msgSender() == privatePlacementLockedWallet.beneficiary(),
            "Wallet owner only"
        );

        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------------- Strategic Partner --------------------------- */
    function unlockStrategicPartnerWallet_1() external lockedWalletInitiated {
        require(
            _msgSender() == strategicPartnerLockedWallet_1.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_1
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_2() external lockedWalletInitiated {
        require(
            _msgSender() == strategicPartnerLockedWallet_2.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_2
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_3() external lockedWalletInitiated {
        require(
            _msgSender() == strategicPartnerLockedWallet_3.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_3
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ---------------------- Team and Project Coordinator ---------------------- */
    function unlockTeamAndProjectCoordinatorWallet_1()
        external
        lockedWalletInitiated
    {
        require(
            _msgSender() ==
                teamAndProjectCoordinatorLockedWallet_1.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_2()
        external
        lockedWalletInitiated
    {
        require(
            _msgSender() ==
                teamAndProjectCoordinatorLockedWallet_2.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_3()
        external
        lockedWalletInitiated
    {
        require(
            _msgSender() ==
                teamAndProjectCoordinatorLockedWallet_3.beneficiary(),
            "Wallet owner only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Private Sale                                */
    /* -------------------------------------------------------------------------- */

    function addBeneficiary(address user, uint256 amount) external onlyOwner {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(amount > 0, "Cannot add beneficiary with 0 amount");
        _privateSale -= amount;
        _addBeneficiary(user, amount);
        emit AddPrivateSale(msg.sender, user, amount);
    }

    function addMultipleBeneficiary(Beneficiary[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i++) {
            _privateSale -= benefs[i].amount;
            _addBeneficiary(benefs[i].user, benefs[i].amount);
            emit AddPrivateSale(msg.sender, benefs[i].user, benefs[i].amount);
        }
    }

    function deleteBeneficiary(address user) external onlyOwner {
        require(privateSaleStatus == true, "Private Sale not yet started");
        uint256 amount = _deleteBeneficiary(user);
        _privateSale += amount;
        emit DeletePrivateSale(msg.sender, user);
    }

    function deleteMultipleBeneficiary(address[] calldata benefs)
        external
        onlyOwner
    {
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i++) {
            uint256 amount = _deleteBeneficiary(benefs[i]);
            _privateSale += amount;
            emit DeletePrivateSale(msg.sender, benefs[i]);
        }
    }

    function claimPrivateSale() external {
        uint256 privateSale = _releaseClaimable(_msgSender());
        _balances[_msgSender()] = _balances[_msgSender()].add(privateSale);
    }
}
