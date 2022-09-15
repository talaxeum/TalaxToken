// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./governance/ERC20Votes.sol";

import "./Data.sol";
import "./Interfaces.sol";
import "./VestingWallet.sol";

/**
 * @notice Custom error
 */
error Airdrop__notStarted();
error Init__nothingToInitialize();
error Init__notInitialized();
error Staking__optionNotExist();
error Tax__maxFivePercent();
error Ownable__notWalletOwner();

contract TalaxToken is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    using SafeMath for uint256;

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
    // Changeable address by owner
    address public timelockController;

    address public private_placement_address =
        0xf8e81D47203A594245E36C48e151709F0C19fBe8; //test account 1
    // address public private_placement_address = 0x07A20dc6722563783e44BA8EDCA08c774621125E;

    address public strategic_partner_address = address(0);

    /*
     * Notes
     * S     = Staking
     * PP    = Private Placement
     * PS    = Private Sale
     * M     = Marketing
     * SP    = Strategic Partner
     * TPC   = Team and Project Coordinator
     */

    IStakable S_contract;
    IWhitelist PP_contract;
    IWhitelist PS_contract;
    IWhitelist SP_contract;
    VestingWallet public M_contract_1;
    VestingWallet public M_contract_2;
    VestingWallet public M_contract_3;
    VestingWallet public TPC_contract_1;
    VestingWallet public TPC_contract_2;
    VestingWallet public TPC_contract_3;

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             EVENTS                                             */
    /* ---------------------------------------------------------------------------------------------- */

    event ChangeTax(address indexed who, uint256 amount);
    event ChangeAirdropStatus(address indexed who, bool status);

    event Change_PP_Address(address indexed to);

    event ChangeStrategicPartnerAddress(
        address from,
        address indexed to1,
        address indexed to2,
        address indexed to3
    );

    event AddBeneficiary(address indexed from, Beneficiary[] beneficiary);
    event DeleteBeneficiary(address indexed from, address[] beneficiary);

    event InitiateWhitelist(address indexed from);
    event InitiateVesting(address indexed from);

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

    constructor() ERC20("Talaxeum", "TALAX") ERC20Permit("Talaxeum") {
        _totalSupply = 21 * 1e9 * 1e18;

        // later divided by 100 to make percentage
        taxFee = 1;

        // Staking APY in percentage
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[365 days] = 8;

        /*
         * 1.     Public Sale                   -
         * 2.     Private Placement             -
         * 3.     Private Sale                  - // Whitelist
         * 4.     Strategic Partner & Advisory  - // Whitelist
         * 5.     Team                          -
         * 6.     Marketing                     -
         * 7.     CEX Listing                   -
         * 8.     Staking Reward                -
         * 9.     Liquidity Reserve             -
         * 10.    DAO Project Launcher Pool     -
         */

        /* --------------------------------------------- TGE -------------------------------------------- */
        _balances[public_sale_address] = 193200 * 1e3 * 1e18;
        _balances[marketing_address_1] = 14000 * 1e3 * 1e18;
        _balances[marketing_address_2] = 14000 * 1e3 * 1e18;
        _balances[marketing_address_3] = 14000 * 1e3 * 1e18;
        _balances[cex_listing_address] = 525000 * 1e3 * 1e18;
        _balances[staking_reward] = 56538462 * 1e18;
        _balances[msg.sender] = 88846154 * 1e18; // for testing and staging
        // _balances[address(this)] = 88846154 * 1e18;
        // _balances[timeLockController] = 88846154 * 1e18;
        _balances[dao_pool] = 100961538 * 1e18;

        /* ------------------------------------- Interfaces Contract ------------------------------------ */
        S_contract = IStakable(stake_address);
        PP_contract = IWhitelist(private_placement_address);
        PS_contract = IWhitelist(private_sale_address);
        SP_contract = IWhitelist(strategic_partner_address);
        /* ---------------------------------------------- - --------------------------------------------- */

        // Public Sale, CEX Listing - EOA Type Balance
        // Private Sale - Multilock.sol
        // Private Placement, Strategic Partner & Advisory, Team and Project Contributor, Marketing - Locked Wallet Type Balance
        // Staking Reward, Liquidity Reserve, DAO Project Pool - Smart Contract Balance
        _totalSupply = _totalSupply.sub(
            14114100 * 1e3 * 1e18,
            "Insufficient Total Supply"
        );

        //Transfer Ownership to TimelockController address
    }

    fallback() external payable {
        // Add any ethers send to this address to team and project coordinators addresses
        _addThirdOfValue(msg.value);
    }

    receive() external payable {
        _addThirdOfValue(msg.value);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            MODIFIERS                                           */
    /* ---------------------------------------------------------------------------------------------- */
    function _isInitializationStarted() internal view {
        if (initializationStatus != true) {
            revert Init__notInitialized();
        }
    }

    modifier isInitialized() {
        _isInitializationStarted();
        _;
    }

    function _onlyWalletOwner(address walletOwner) internal view {
        if (_msgSender() != walletOwner) {
            revert Ownable__notWalletOwner();
        }
    }

    modifier onlyWalletOwner(address walletOwner) {
        _onlyWalletOwner(walletOwner);
        _;
    }

    /* ------------------------------------ ERC20 token functions ----------------------------------- */

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

        uint256 tax = SafeMath.div(SafeMath.mul(amount, taxFee), 100);
        uint256 taxedAmount = SafeMath.sub(amount, tax);

        uint256 teamFee = SafeMath.div(SafeMath.mul(taxedAmount, 2), 10);
        uint256 liquidityFee = SafeMath.div(SafeMath.mul(taxedAmount, 8), 10);

        _addThirdOfValue(teamFee);
        _balances[address(this)] = _balances[address(this)].add(liquidityFee);

        _balances[to] = _balances[to].add(taxedAmount);
        emit Transfer(from, to, taxedAmount);
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

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                  End of ERC20 token functions                                  */
    /* ---------------------------------------------------------------------------------------------- */

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

    /* --------------------------------- Added functions (external) --------------------------------- */

    function startTransferDAOVoting() external onlyOwner {
        //moveable
        S_contract.startVoting();
    }

    function transferToDAOPool(uint256 amount_) external {
        // removeable if address exist
        _balances[msg.sender] = _balances[msg.sender].sub(amount_);
        daoProjectPool += amount_;
    }

    function transferDAOPool(address to_, uint256 amount_) external onlyOwner {
        // removeable if address exist
        bool result = S_contract.getVotingResult();

        if (result == true) {
            daoProjectPool = daoProjectPool.sub(amount_);
            _balances[to_] = _balances[to_].add(amount_);
        }
        S_contract.stopVoting();

        emit TransferDAOPool(address(this), to_, amount_);
    }

    function mintStakingReward(uint256 amount_) public onlyOwner {
        // removeable if address exist
        _mintStakingReward(amount_);
    }

    function mintLiquidityReserve(uint256 amount_) public onlyOwner {
        // removeable if address exist
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
        emit Transfer(address(0), address(this), amount_);
    }

    function burnStakingReward(uint256 amount_) external onlyOwner {
        // removeable if address exist
        stakingReward = stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit TransferStakingReward(address(this), address(0), amount_);
    }

    function burnLiquidityReserve(uint256 amount_) external onlyOwner {
        // removeable if address exist
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(address(this), address(0), amount_);
    }

    function changeTaxFee(uint8 taxFee_) external onlyOwner {
        if (taxFee_ > 5) {
            revert Tax__maxFivePercent();
        }
        taxFee = taxFee_;
        emit ChangeTax(_msgSender(), taxFee_);
    }

    /* ------------------------ Stake function with burn function ------------------------ */
    function stake(uint256 _amount, uint256 _stakePeriod) external {
        if (
            !(_stakePeriod == 90 days ||
                _stakePeriod == 180 days ||
                _stakePeriod == 365 days)
        ) {
            revert Staking__optionNotExist();
        }

        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);

        S_contract.stake(
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
        (uint256 amount_, uint256 reward_) = S_contract.withdrawStake(
            msg.sender
        );
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        _mintStakingReward(reward_);
        _balances[address(this)] -= amount_;
        stakingReward = stakingReward.sub(reward_);
        _totalSupply = _totalSupply.add(amount_);
        _balances[_msgSender()] = _balances[_msgSender()].add(
            amount_ + reward_
        );
    }

    function claimAirdrop() external isInitialized {
        if (airdropStatus != true) {
            revert Airdrop__notStarted();
        }
        uint256 airdrop = S_contract.claimAirdrop(_msgSender());
        _balances[address(this)] = _balances[address(this)].sub(airdrop);
        _balances[_msgSender()] = _balances[_msgSender()].add(airdrop);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Vesting                                            */
    /* ---------------------------------------------------------------------------------------------- */
    function initiateVesting_Whitelist_Airdrop() external onlyOwner {
        if (initializationStatus != false) {
            revert Init__nothingToInitialize();
        }

        initializationStatus = true;
        M_contract_1 = new VestingWallet(
            marketing_address_1,
            uint64(vesting_start),
            35 * 30 days
        );
        M_contract_2 = new VestingWallet(
            marketing_address_2,
            uint64(vesting_start),
            35 * 30 days
        );
        M_contract_3 = new VestingWallet(
            marketing_address_3,
            uint64(vesting_start),
            35 * 30 days
        );

        TPC_contract_1 = new VestingWallet(
            team_and_project_coordinator_address_1,
            uint64(vesting_start) + (11 * 30 days),
            36 * 30 days
        );
        TPC_contract_2 = new VestingWallet(
            team_and_project_coordinator_address_2,
            uint64(vesting_start) + (11 * 30 days),
            36 * 30 days
        );
        TPC_contract_3 = new VestingWallet(
            team_and_project_coordinator_address_3,
            uint64(vesting_start) + (11 * 30 days),
            36 * 30 days
        );
        emit InitiateVesting(_msgSender());

        // PP_contract.initiateWhitelist();
        PS_contract.initiateWhitelist();
        // SP_contract.initiateWhitelist();
        emit InitiateWhitelist(_msgSender());

        airdropStatus = true;
        S_contract.startAirdropSince();
        emit ChangeAirdropStatus(_msgSender(), airdropStatus);
    }

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            Whitelist                                           */
    /* ---------------------------------------------------------------------------------------------- */

    function unsafeInc(uint256 x) internal pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function _checkBeneficiary(uint256 len) internal pure {
        require(len > 0, "Input can't empty");
    }

    /* ------------------------------------------ moveable ------------------------------------------ */
    /**
     * ? Token needs to be transferred to the vesting wallet
     * ? When user want to claim the vesting, vesting wallet will transfer the token to the beneficiary address
     */

    function add_PP_Beneficiaries(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            PP_contract.addBeneficiary(benefs[i].user, benefs[i].amount);
        }
        emit AddBeneficiary(msg.sender, benefs);
    }

    function add_PS_Beneficiaries(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            PS_contract.addBeneficiary(benefs[i].user, benefs[i].amount);
        }
        emit AddBeneficiary(msg.sender, benefs);
    }

    function add_SP_Beneficiaries(Beneficiary[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            SP_contract.addBeneficiary(benefs[i].user, benefs[i].amount);
        }
        emit AddBeneficiary(msg.sender, benefs);
    }

    function delete_PP_Beneficiaries(address[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            PP_contract.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiary(msg.sender, benefs);
    }

    function delete_PS_Beneficiaries(address[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            PS_contract.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiary(msg.sender, benefs);
    }

    function delete_SP_Beneficiaries(address[] calldata benefs)
        external
        onlyOwner
        isInitialized
    {
        _checkBeneficiary(benefs.length);
        for (uint256 i = 0; i < benefs.length; i = unsafeInc(i)) {
            SP_contract.deleteBeneficiary(benefs[i]);
        }
        emit DeleteBeneficiary(msg.sender, benefs);
    }

    /* ---------------------------------------------- - --------------------------------------------- */

    function claim_PP() external isInitialized {
        _balances[_msgSender()] = _balances[_msgSender()].add(
            PP_contract.releaseClaimable(_msgSender())
        );
    }

    function claim_PS() external isInitialized {
        _balances[_msgSender()] = _balances[_msgSender()].add(
            PP_contract.releaseClaimable(_msgSender())
        );
    }

    function claim_SP() external isInitialized {
        _balances[_msgSender()] = _balances[_msgSender()].add(
            SP_contract.releaseClaimable(_msgSender())
        );
    }
}
