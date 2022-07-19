// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Data.sol";
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
    uint256 public daoProjectPool;
    uint8 public taxFee;

    bool public airdropStatus;
    bool public lockedWalletStatus;
    bool public privateSaleStatus;

    /* ------------------------------------------ Addresses ----------------------------------------- */

    address private _timelockController;

    /* ---------------------------------- later moved into Data.sol --------------------------------- */
    address private cex_listing_address;
    /* ---------------------------------------------- - --------------------------------------------- */

    // Changeable address by owner
    address internal private_placement_address =
        0x07A20dc6722563783e44BA8EDCA08c774621125E;
    address internal strategic_partner_address_1 =
        0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
    address internal strategic_partner_address_2 =
        0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
    address internal strategic_partner_address_3 =
        0xAeB26fB84d0E2b3B353Cd50f0A29FD40C916d2Ab;

    /* ------------------------------------------ Lockable ------------------------------------------ */

    Lockable internal privatePlacementLockedWallet;
    Lockable internal marketingLockedWallet_1;
    Lockable internal marketingLockedWallet_2;
    Lockable internal marketingLockedWallet_3;
    Lockable internal strategicPartnerLockedWallet_1;
    Lockable internal strategicPartnerLockedWallet_2;
    Lockable internal strategicPartnerLockedWallet_3;
    Lockable internal teamAndProjectCoordinatorLockedWallet_1;
    Lockable internal teamAndProjectCoordinatorLockedWallet_2;
    Lockable internal teamAndProjectCoordinatorLockedWallet_3;

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

        airdropStatus = false;

        // Staking APY in percentage
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[360 days] = 8;

        // Public Sale
        _balances[public_sale_address] = 396900 * 1e3 * 1e18;
        // CEX Listing
        _balances[cex_listing_address] = 1050000 * 1e3 * 1e18;

        // Private Sale (MultiLockable)
        privateSale = 1467900 * 1e3 * 1e18;
        // Staking Reward (stored inside this contract)
        stakingReward = 2685900 * 1e3 * 1e18;
        // DAO Project Pool
        daoProjectPool = 4200000 * 1e3 * 1e18;
        // Liquitidity Reserve (This Contract)
        _balances[address(this)] = 4200000 * 1e3 * 1e18;

        /* ---------------------------------------- Locked Wallet --------------------------------------- */
        privatePlacementLockedWallet = new Lockable(
            699300 * 1e3 * 1e18,
            private_placement_address
        );

        marketingLockedWallet_1 = new Lockable(
            700000 * 1e3 * 1e18,
            marketing_address_1
        );
        marketingLockedWallet_2 = new Lockable(
            700000 * 1e3 * 1e18,
            marketing_address_2
        );
        marketingLockedWallet_3 = new Lockable(
            700000 * 1e3 * 1e18,
            marketing_address_3
        );

        strategicPartnerLockedWallet_1 = new Lockable(
            700000 * 1e3 * 1e18,
            strategic_partner_address_1
        );
        strategicPartnerLockedWallet_2 = new Lockable(
            700000 * 1e3 * 1e18,
            strategic_partner_address_2
        );
        strategicPartnerLockedWallet_3 = new Lockable(
            700000 * 1e3 * 1e18,
            strategic_partner_address_3
        );

        teamAndProjectCoordinatorLockedWallet_1 = new Lockable(
            700000 * 1e3 * 1e18,
            team_and_project_coordinator_address_1
        );
        teamAndProjectCoordinatorLockedWallet_2 = new Lockable(
            700000 * 1e3 * 1e18,
            team_and_project_coordinator_address_2
        );
        teamAndProjectCoordinatorLockedWallet_3 = new Lockable(
            700000 * 1e3 * 1e18,
            team_and_project_coordinator_address_3
        );

        // Public Sale, CEX Listing - EOA Type Balance
        // Private Placement, Strategic Partner & Advisory, Team and Project Contributor, Marketing - Locked Wallet Type Balance
        // Staking Reward, Liquidity Reserve, DAO Project Pool - Smart Contract Balance
        _totalSupply = _totalSupply.sub(
            14114100 * 1e3 * 1e18,
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

    event ChangePrivatePlacementAddress(address indexed to);

    event ChangeStrategicPartnerAddress(
        address indexed to1,
        address indexed to2,
        address indexed to3
    );

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
    function _isLockedWalletInitiated() internal view {
        require(lockedWalletStatus == true, "Locked Wallet not yet started");
    }

    modifier lockedWalletInitiated() {
        _isLockedWalletInitiated();
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

    function _mintStakingReward(uint256 amount_) internal {
        stakingReward = stakingReward.add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit TransferStakingReward(address(0), address(this), amount_);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                       External Functions                                       */
    /* ---------------------------------------------------------------------------------------------- */

    function transferToDAOPool(uint256 amount_) external {
        _balances[msg.sender] = _balances[msg.sender].sub(amount_);
        daoProjectPool += amount_;
    }

    function transferDAOPool(address to_, uint256 amount_) external onlyOwner {
        bool result = _getVotingResult();

        if (result == true) {
            daoProjectPool = daoProjectPool.sub(amount_);
            _balances[to_] = _balances[to_].add(amount_);
        }
        _stopVoting();
    }

    function changePrivatePlacementAddress(address _input) external onlyOwner {
        private_placement_address = _input;
        emit ChangePrivatePlacementAddress(_input);
    }

    function changeStrategicPartnerAddress1(
        address address1,
        address address2,
        address address3
    ) external onlyOwner {
        strategic_partner_address_1 = address1;
        strategic_partner_address_2 = address2;
        strategic_partner_address_3 = address3;
        emit ChangeStrategicPartnerAddress(address1, address2, address3);
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

    function changeTaxFee(uint8 taxFee_) external onlyOwner {
        require(taxFee_ < 5, "Tax Fee maximum is 5%");
        taxFee = taxFee_;
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

        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);

        _stake(
            msg.sender,
            _amount,
            _stakePeriod,
            _stakingPackage[_stakePeriod]
        );

        // Stake amount goes to liquidity reserve
        _balances[address(this)] = _balances[address(this)].add(_amount);
    }

    /* ---- withdrawStake is used to withdraw stakes from the account holder ---- */
    function withdrawStake() external {
        (uint256 amount_, uint256 reward_) = _withdrawStake(msg.sender);
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintStakingReward(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount_);
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
        marketingLockedWallet_1.initiateLockedWallet();
        marketingLockedWallet_2.initiateLockedWallet();
        marketingLockedWallet_3.initiateLockedWallet();
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
        _startAirdropSince();
        emit ChangeAirdropStatus(_msgSender(), airdropStatus);
    }

    /* -------------------------------------- Private Placement ------------------------------------- */
    function unlockPrivatePlacementWallet()
        external
        lockedWalletInitiated
        onlyWalletOwner(privatePlacementLockedWallet.beneficiary())
    {
        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* ------------------------------------------ Marketing ----------------------------------------- */
    function unlockMarketingWallet_1()
        external
        lockedWalletInitiated
        onlyWalletOwner(marketingLockedWallet_1.beneficiary())
    {
        uint256 timeLockedAmount = marketingLockedWallet_1.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockMarketingWallet_2()
        external
        lockedWalletInitiated
        onlyWalletOwner(marketingLockedWallet_2.beneficiary())
    {
        uint256 timeLockedAmount = marketingLockedWallet_2.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockMarketingWallet_3()
        external
        lockedWalletInitiated
        onlyWalletOwner(marketingLockedWallet_3.beneficiary())
    {
        uint256 timeLockedAmount = marketingLockedWallet_3.releaseClaimable(
            marketingReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /* -------------------------------------- Strategic Partner ------------------------------------- */
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

    /* -------------------------------- Team and Project Coordinator -------------------------------- */
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

    function _checkBeneficiaryAmount(uint256 amount) internal pure {
        require(amount != 0, "Amount cannot be zero");
    }

    function addMultipleBeneficiary(Beneficiary[] calldata benefs)
        external
        onlyOwner
    {
        uint256 cachePrivateSale;
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to add");
        for (uint256 i = 0; i < benefs.length; i++) {
            _checkBeneficiaryAmount(benefs[i].amount);
            cachePrivateSale += benefs[i].amount;
            _addBeneficiary(benefs[i].user, benefs[i].amount);
            emit AddPrivateSale(msg.sender, benefs[i].user, benefs[i].amount);
        }
        privateSale = privateSale.sub(cachePrivateSale);
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
        uint256 cachePrivateSale;
        require(privateSaleStatus == true, "Private Sale not yet started");
        require(benefs.length > 0, "Nothing to delete");
        for (uint256 i = 0; i < benefs.length; i++) {
            uint256 amount = _deleteBeneficiary(benefs[i]);
            cachePrivateSale += amount;
            emit DeletePrivateSale(msg.sender, benefs[i]);
        }
        privateSale = privateSale.add(cachePrivateSale);
    }

    function claimPrivateSale() external {
        _balances[_msgSender()] = _balances[_msgSender()].add(
            _releaseClaimable(_msgSender())
        );
    }
}
