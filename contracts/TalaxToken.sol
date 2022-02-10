// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./src/Context.sol";
import "./src/IBEP20.sol";
import "./src/Ownable.sol";
import "./src/SafeMath.sol";
import "./Stakable.sol";
import "./Lockable.sol";
import "./MultiLockable.sol";

contract TalaxToken is Context, IBEP20, Ownable, Stakable {
	using SafeMath for uint256;

	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;

	mapping(uint256 => uint256) private _stakingPackage;

	uint16 public _taxFee;

	uint256 private _totalSupply;
	uint8 private _decimals;
	string private _symbol;
	string private _name;

	// balances
	uint256 private _publicSale;
	uint256 private _privateSale;
	uint256 private _stakingReward;
	uint256 private _liquidityReserve;

	uint256 private _devPool;
	uint256 private _teamAndProjectCoordinator;

	uint256 private _privatePlacement;
	uint256 private _strategicPartner;

	address public_sale_address;
	address private_sale_address;
	address staking_reward_address;
	address liquidity_reserve_address;

	address dev_pool_address;
	address team_and_project_coordinator_address;

	Lockable public devPoolLockedWallet;
	Lockable public teamAndProjectCoordinatorLockedWallet;

	// MultiLockable public privateSaleLockedWallet;
	MultiLockable public privatePlacementLockedWallet;
	MultiLockable public strategicPartnerLockedWallet;

	constructor() {
		_name = "TALAXEUM";
		_symbol = "TALAX";
		_decimals = 18;
		_totalSupply = 210 * 1e6 * 10**18;

		// public_sale_address = [ADDRESS];
		// private_sale_address = [ADDRESS];
		// staking_reward_address = [ADDRESS];
		// liquidity_reserve_address = [ADDRESS];
		// dev_pool_address = [ADDRESS];
		// team_and_project_coordinator_address = [ADDRESS];

		_privateSale = 6993 * 1e3 * 10**18;
		_publicSale = 42 * 1e6 * 10**18;
		_stakingReward = 17514 * 1e3 * 10**18;
		_liquidityReserve = 52500 * 1e3 * 10**18;

		_balances[private_sale_address] = _privateSale;
		_balances[public_sale_address] = _publicSale;

		_totalSupply = _totalSupply.sub(
			_privateSale,
			"TalaxToken: Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			_publicSale,
			"TalaxToken: Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			_stakingReward,
			"TalaxToken: Cannot transfer more than total supply"
		);

		devPoolLockedWallet = new Lockable(42 * 1e6 * 10**18, dev_pool_address);
		teamAndProjectCoordinatorLockedWallet = new Lockable(
			31500 * 1e3 * 10**18,
			team_and_project_coordinator_address
		);

		privatePlacementLockedWallet = new MultiLockable(6993 * 1e3 * 10**18);
		strategicPartnerLockedWallet = new MultiLockable(10500 * 1e3 * 10**18);

		// Locked Wallet
		// Dev Pool
		_totalSupply = _totalSupply.sub(
			42 * 1e6 * 10**18,
			"TalaxToken: Cannot transfer more than total supply"
		);
		// Team and Project Coordinator
		_totalSupply = _totalSupply.sub(
			31500 * 1e3 * 10**18,
			"TalaxToken: Cannot transfer more than total supply"
		);

		// MultiLocked Wallet
		// Private Placement
		_totalSupply = _totalSupply.sub(
			6993 * 1e3 * 10**18,
			"TalaxToken: Cannot transfer more than total supply"
		);
		// Strategic Partner
		_totalSupply = _totalSupply.sub(
			10500 * 1e3 * 10**18,
			"TalaxToken: Cannot transfer more than total supply"
		);

		// later divided by 100 to make percentage
		_taxFee = 1;

		// in percentage
		_stakingPackage[30 days] = 5;
		_stakingPackage[90 days] = 6;
		_stakingPackage[180 days] = 7;
		_stakingPackage[365 days] = 8;

		_balances[_msgSender()] = _totalSupply;
	}

	fallback() external payable {
		_balances[team_and_project_coordinator_address] = _balances[
			team_and_project_coordinator_address
		].add(msg.value);
	}

	receive() external payable {}

	event ChangeTax(address indexed who, uint256 amount);

	event AddPrivatePlacement(address indexed from, address indexed who);
	event DeletePrivatePlacement(address indexed from, address indexed who);

	event AddStrategicPartner(address indexed from, address indexed who);
	event DeleteStrategicPartner(address indexed from, address indexed who);

	event ChangePublicSaleAddress(address indexed from, address indexed to);
	event ChangeLiquidityReserveAddress(
		address indexed from,
		address indexed to
	);
	event ChangeDevPoolAddress(address indexed from, address indexed to);

	function devPool() external view returns (Lockable) {
		return devPoolLockedWallet;
	}

	function teamAndProject() external view returns (Lockable) {
		return teamAndProjectCoordinatorLockedWallet;
	}

	function privatePlacement() external view returns (MultiLockable) {
		return privatePlacementLockedWallet;
	}

	function stratPartner() external view returns (MultiLockable) {
		return strategicPartnerLockedWallet;
	}

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

	function stakingPackage(uint256 index) external view returns (uint256) {
		return _stakingPackage[index];
	}

	function taxFee() external view returns (uint256) {
		return _taxFee;
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
	 * @dev this is the release rate for partial token release
	 */
	function devPoolReleaseRate() internal pure returns (uint256[43] memory) {
		return [
			SafeMath.div(3 * 1e16, 42),
			0,
			0,
			0,
			SafeMath.div(3 * 1e16, 42),
			0,
			0,
			SafeMath.div(3 * 1e16, 42),
			0,
			0,
			SafeMath.div(3 * 1e16, 42),
			0,
			0,
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42),
			SafeMath.div(1 * 1e16, 42)
		];
	}

	function strategicPartnerReleaseRate()
		internal
		pure
		returns (uint256[43] memory)
	{
		return [
			SafeMath.div(10 * 1e16, 105),
			0,
			0,
			0,
			SafeMath.div(10 * 1e16, 105),
			0,
			0,
			SafeMath.div(10 * 1e16, 105),
			0,
			0,
			SafeMath.div(10 * 1e16, 105),
			0,
			0,
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000),
			SafeMath.div(216667 * 1e16, 10500000)
		];
	}

	function privatePlacementReleaseRate()
		internal
		pure
		returns (uint256[43] memory)
	{
		return [
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(500 * 1e16, 6993),
			SafeMath.div(493 * 1e16, 6993),
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

	function teamAndProjectCoordinatorReleaseRate()
		internal
		pure
		returns (uint256[43] memory)
	{
		return [
			SafeMath.div(35 * 1e16, 315),
			0,
			0,
			0,
			SafeMath.div(30 * 1e16, 315),
			0,
			0,
			SafeMath.div(30 * 1e16, 315),
			0,
			0,
			SafeMath.div(30 * 1e16, 315),
			0,
			0,
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
			SafeMath.div(10 * 1e16, 315),
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
				"TalaxToken: transfer amount exceeds allowance"
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
		external
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
		external
		returns (bool)
	{
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(
				subtractedValue,
				"TalaxToken: decreased allowance below zero"
			)
		);
		return true;
	}

	function burnStakingReward(uint256 amount_)
		external
		onlyOwner
		returns (bool)
	{
		require(
			amount_ < _stakingReward,
			"TalaxToken: Amount burnt cannot be larger than Staking Reward"
		);
		_stakingReward = _stakingReward.sub(amount_);
		_totalSupply = _totalSupply.sub(amount_);
		emit Transfer(staking_reward_address, address(0), amount_);

		return true;
	}

	function mintStakingReward(uint256 amount_)
		external
		onlyOwner
		returns (bool)
	{
		require(amount_ != 0, "Amount mint cannot be 0");
		_stakingReward = _stakingReward.add(amount_);
		_totalSupply = _totalSupply.add(amount_);
		emit Transfer(address(0), staking_reward_address, amount_);

		return true;
	}

	function mintLiquidityReserve(uint256 amount_)
		public
		onlyOwner
		returns (bool)
	{
		require(amount_ != 0, "Amount mint cannot be 0");
		_liquidityReserve = _liquidityReserve.add(amount_);
		_totalSupply = _totalSupply.add(amount_);
		emit Transfer(address(0), liquidity_reserve_address, amount_);

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
	function mint(uint256 amount) external onlyOwner returns (bool) {
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
		address sender,
		address recipient,
		uint256 amount
	) internal {
		require(sender != address(0), "TalaxToken: transfer from the zero address");
		require(recipient != address(0), "TalaxToken: transfer to the zero address");

		uint256 tax = SafeMath.div(SafeMath.mul(amount, _taxFee), 100);
		uint256 taxedAmount = SafeMath.sub(amount, tax);

		uint256 teamFee = SafeMath.mul(taxedAmount, SafeMath.div(2, 10));
		uint256 liquidityFee = SafeMath.mul(taxedAmount, SafeMath.div(8, 10));

		_balances[team_and_project_coordinator_address] = _balances[
			team_and_project_coordinator_address
		].add(teamFee);
		_balances[liquidity_reserve_address] = _balances[
			liquidity_reserve_address
		].add(liquidityFee);

		_balances[sender] = _balances[sender].sub(
			amount,
			"TalaxToken: transfer amount exceeds balance"
		);
		_balances[recipient] = _balances[recipient].add(taxedAmount);
		emit Transfer(sender, recipient, taxedAmount);
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
		require(account != address(0), "TalaxToken: mint to the zero address");

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
		require(account != address(0), "TalaxToken: burn from the zero address");

		_balances[account] = _balances[account].sub(
			amount,
			"TalaxToken: burn amount exceeds balance"
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
		require(owner != address(0), "TalaxToken: approve from the zero address");
		require(spender != address(0), "TalaxToken: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _changeTaxFee(uint16 taxFee_) internal {
		_taxFee = taxFee_;
		emit ChangeTax(msg.sender, taxFee_);
	}

	function _changePublicSaleAddress(address new_) internal {
		public_sale_address = new_;
		emit ChangePublicSaleAddress(public_sale_address, new_);
	}

	function _changeLiquidityReserveAddress(address new_) internal {
		liquidity_reserve_address = new_;
		emit ChangeLiquidityReserveAddress(liquidity_reserve_address, new_);
	}

	function _changeDevPoolAddress(address new_) internal {
		dev_pool_address = new_;
		emit ChangeDevPoolAddress(dev_pool_address, new_);
	}

	function changeTaxFee(uint16 taxFee_) external onlyOwner returns (bool) {
		_changeTaxFee(taxFee_);
		return true;
	}

	/**
	 * @dev Transfer all the balance of an address, delete the old address, and change to new address
	 */
	function changePublicSaleAddress(address new_) public onlyOwner {
		_balances[new_] = _balances[public_sale_address];
		emit Transfer(
			public_sale_address,
			new_,
			_balances[public_sale_address]
		);
		delete _balances[public_sale_address];
		_changePublicSaleAddress(new_);
	}

	function changeLiquidityReserveAddress(address new_) public onlyOwner {
		_balances[new_] = _balances[liquidity_reserve_address];
		emit Transfer(
			liquidity_reserve_address,
			new_,
			_balances[liquidity_reserve_address]
		);
		delete _balances[liquidity_reserve_address];
		_changePublicSaleAddress(new_);
	}

	function changeDevPoolAddress(address new_) public onlyOwner {
		_balances[new_] = _balances[dev_pool_address];
		emit Transfer(dev_pool_address, new_, _balances[dev_pool_address]);
		delete _balances[dev_pool_address];
		_changeDevPoolAddress(new_);
	}

	/**
	 * Add functionality like burn to the _stake afunction
	 *
	 */
	function stake(uint256 _amount, uint256 _stakePeriod) external {
		// Make sure staker actually is good for it
		require(
			_stakePeriod == 30 days ||
				_stakePeriod == 90 days ||
				_stakePeriod == 180 days ||
				_stakePeriod == 365 days,
			"TalaxToken: Staking package option not exist"
		);
		require(
			_amount < _balances[_msgSender()],
			"TalaxToken: Cannot stake more than you own"
		);

		_stake(_amount, _stakePeriod, _stakingPackage[_stakePeriod]);
		// Burn the amount of tokens on the sender
		_burn(_msgSender(), _amount);
		// Stake amount goes to liquidity reserve
		_liquidityReserve.add(_amount);
	}

	/**
	 * @notice withdrawStake is used to withdraw stakes from the account holder
	 */
	function withdrawStake(uint256 amount, uint256 stake_index) external {
		(uint256 amount_, uint256 reward_) = _withdrawStake(
			amount,
			stake_index
		);
		// Return staked tokens to user
		// Amount staked on liquidity reserved goes to the user
		// Staking reward, calculated from Stakable.sol, is minted and substracted
		mintLiquidityReserve(reward_);
		_liquidityReserve.sub(amount_);
		_liquidityReserve.sub(reward_);
		_mint(_msgSender(), amount_ + reward_);
	}

	function withdrawAllStake(uint256 stake_index) external {
		(uint256 amount_, uint256 reward_) = _withdrawAllStake(stake_index);
		// Return staked tokens to user
		// Amount staked on liquidity reserved goes to the user
		// Staking reward, calculated from Stakable.sol, is minted and substracted
		mintLiquidityReserve(reward_);
		_liquidityReserve.sub(amount_);
		_liquidityReserve.sub(reward_);
		_mint(_msgSender(), amount_ + reward_);
	}

	/**
	 * @dev LockedWallet: Dev Pool Locked Wallet
	 */
	function unlockDevPoolWallet() external {
		require(
			msg.sender == devPoolLockedWallet.beneficiary() ||
				msg.sender == owner(),
			"TalaxToken: Only claimable by User of this address or owner"
		);
		uint256 timeLockedAmount = devPoolLockedWallet.releaseClaimable(
			devPoolReleaseRate()
		);

		_balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
	}

	/**
	 * @dev LockedWallet: Team And Project Coordinator Locked Wallet
	 */
	function unlockTeamAndProjectCoordinatorWallet() external {
		require(
			team_and_project_coordinator_address ==
				teamAndProjectCoordinatorLockedWallet.beneficiary() ||
				msg.sender == this.getOwner(),
			"TalaxToken: Only claimable by User of this address or owner"
		);
		uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet
			.releaseClaimable(teamAndProjectCoordinatorReleaseRate());

		_balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
	}

	/**
	 * @dev MultiLockedWallet: PrivatePlacement Locked Wallet
	 */
	function addPrivatePlacementUser(address user_, uint256 amount_)
		external
		onlyOwner
	{
		require(
			user_ != address(0),
			"TalaxToken: Cannot add empty user"
		);
		require(amount_ > 0, "TalaxToken: Cannot use zero amount");

		privatePlacementLockedWallet.lockWallet(amount_, user_);
		emit AddPrivatePlacement(msg.sender, user_);
	}

	function deletePrivatePlacementUser(address user_) external onlyOwner {
		require(
			user_ != address(0),
			"TalaxToken: Cannot delete empty user"
		);

		privatePlacementLockedWallet.deleteUser(user_);
		emit DeletePrivatePlacement(msg.sender, user_);
	}

	function releasePrivatePlacement() external onlyOwner {
		uint256 releasedClaimableLockedAmount = privatePlacementLockedWallet
			.releaseClaimable(privatePlacementReleaseRate(), msg.sender);

		_balances[_msgSender()] = _balances[_msgSender()].add(
			releasedClaimableLockedAmount
		);
	}

	/**
	 * @dev MultiLockedWallet: Strategic Partner Locked Wallet
	 */
	function addStrategicPartnerUser(address user_, uint256 amount_)
		external
		onlyOwner
	{
		require(
			user_ != address(0),
			"TalaxToken: Cannot add empty user"
		);
		require(amount_ > 0, "TalaxToken: Cannot use zero amount");

		strategicPartnerLockedWallet.lockWallet(amount_, user_);
		emit AddStrategicPartner(msg.sender, user_);
	}

	function deleteStrategicPartnerUser(address user_) external onlyOwner {
		require(
			user_ != address(0),
			"TalaxToken: Cannot delete empty user"
		);

		strategicPartnerLockedWallet.deleteUser(user_);
		emit DeleteStrategicPartner(msg.sender, user_);
	}

	function releaseStrategicPartner() external onlyOwner {
		uint256 releasedClaimableLockedAmount = strategicPartnerLockedWallet
			.releaseClaimable(strategicPartnerReleaseRate(), msg.sender);

		_balances[_msgSender()] = _balances[_msgSender()].add(
			releasedClaimableLockedAmount
		);
	}
}
