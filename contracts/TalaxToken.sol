// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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
	uint256 private _strategicPartner;

	uint256 private _privatePlacement;
	uint256 private _teamAndProjectCoordinator;

	address public_sale_address;
	address private_sale_address;
	address staking_reward_address;
	address liquidity_reserve_address;

	address dev_pool_address;
	address strategic_partner_address;

	address private_placement_address;
	address team_and_project_coordinator_address;

	// mapping(address => Lockable) public _lockedWallet;

	Lockable public devPoolLockedWallet;
	Lockable public strategicPartnerLockedWallet;

	MultiLockable public privatePlacementLockedWallet;
	MultiLockable public teamAndProjectCoordinatorLockedWallet;

	constructor() {
		_name = "TALAXEUM";
		_symbol = "TALAX";
		_decimals = 18;
		_totalSupply = 210 * 1e6 * 10**18;

		dev_pool_address = 0x933C099dD8CaFd2Ba03D8a76A6DE8f1BaDf77851;
		strategic_partner_address = 0x8ECda324E9b5E3718b4b6673B6652E68A90D057d;

		_publicSale = 42 * 1e6 * 10**18;
		_privateSale = 6993 * 1e3 * 10**18;
		_stakingReward = 17514 * 1e3 * 10**18;
		_liquidityReserve = 52500 * 1e3 * 10**18;

		_totalSupply = _totalSupply.sub(
			_publicSale,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			_privateSale,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			_stakingReward,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			_liquidityReserve,
			"Cannot transfer more than total supply"
		);

		devPoolLockedWallet = new Lockable(42 * 1e6 * 10**18, dev_pool_address);

		strategicPartnerLockedWallet = new Lockable(
			10500 * 1e3 * 10**18,
			strategic_partner_address
		);

		privatePlacementLockedWallet = new MultiLockable(6993 * 1e3 * 10**18);

		teamAndProjectCoordinatorLockedWallet = new MultiLockable(
			31500 * 1e3 * 10**18
		);

		_totalSupply = _totalSupply.sub(
			42 * 1e6 * 10**18,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			10500 * 1e3 * 10**18,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			6993 * 1e3 * 10**18,
			"Cannot transfer more than total supply"
		);
		_totalSupply = _totalSupply.sub(
			31500 * 1e3 * 10**18,
			"Cannot transfer more than total supply"
		);

		// later divided by 100 to make percentage
		_taxFee = 1;

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

	function devPoolRate() public pure returns (uint256[43] memory) {
		return devPoolReleaseRate();
	}

	function privatePlacementRate() public pure returns (uint256[43] memory) {
		return privatePlacementReleaseRate();
	}

	function devPoolMonth() public view returns (uint256) {
		return devPoolLockedWallet._latestClaimMonth();
	}

	function devPool() external view returns (Lockable) {
		return devPoolLockedWallet;
	}

	function stratPartner() external view returns (Lockable) {
		return strategicPartnerLockedWallet;
	}

	function privatePlacement() external view returns (MultiLockable) {
		return privatePlacementLockedWallet;
	}

	function teamAndProject() external view returns (MultiLockable) {
		return teamAndProjectCoordinatorLockedWallet;
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

	function privateSaleReleaseRate()
		internal
		pure
		returns (uint256[43] memory)
	{
		return [
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

	function burnStakingReward(uint256 amount_)
		public
		onlyOwner
		returns (bool)
	{
		require(
			amount_ < _stakingReward,
			"Amount burnt cannot be larger than Staking Reward"
		);
		_stakingReward = _stakingReward.sub(amount_);
		_totalSupply = _totalSupply.sub(amount_);
		return true;
	}

	function mintStakingReward(uint256 amount_)
		public
		onlyOwner
		returns (bool)
	{
		require(amount_ != 0, "Amount mint cannot be 0");
		_stakingReward = _stakingReward.add(amount_);
		_totalSupply = _totalSupply.add(amount_);
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

	function changeTaxFee(uint16 taxFee_) public onlyOwner returns (bool) {
		_changeTaxFee(taxFee_);
		return true;
	}

	function _changeTaxFee(uint16 taxFee_) internal {
		_taxFee = taxFee_;
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
		require(sender != address(0), "BEP20: transfer from the zero address");
		require(recipient != address(0), "BEP20: transfer to the zero address");

		uint256 tax = SafeMath.mul(amount, SafeMath.div(_taxFee, 100));
		uint256 taxedAmount = SafeMath.sub(amount, tax);

		// uint256 teamFee = SafeMath.mul(taxedAmount, SafeMath.div(2,10));
		// uint256 liquidityFee = SafeMath.mul(taxedAmount, SafeMath.div(8,10));

		_balances[sender] = _balances[sender].sub(
			taxedAmount,
			"BEP20: transfer amount exceeds balance"
		);
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
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
	 * Add functionality like burn to the _stake afunction
	 *
	 */
	function stake(uint256 _amount, uint256 _stakePeriod) public {
		// Make sure staker actually is good for it
		require(
			_stakePeriod == 30 days ||
				_stakePeriod == 90 days ||
				_stakePeriod == 180 days ||
				_stakePeriod == 365 days,
			"Staking package option not exist"
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
	function withdrawStake(uint256 amount, uint256 stake_index) public {
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

	function withdrawAllStake(uint256 stake_index) public {
		(uint256 amount_, uint256 reward_) = _withdrawAllStake(stake_index);
		// Return staked tokens to user
		// Amount staked on liquidity reserved goes to the user
		// Staking reward, calculated from Stakable.sol, is minted and substracted
		mintLiquidityReserve(reward_);
		_liquidityReserve.sub(amount_);
		_liquidityReserve.sub(reward_);
		_mint(_msgSender(), amount_ + reward_);
	}

	////////////////////////////////////////////////
	// DEV POOL LOCKED WALLET

	function unlockDevPoolWallet() public {
		require(
			msg.sender == devPoolLockedWallet.beneficiary() ||
				msg.sender == owner(),
			"TokenTimeLock: Only claimable by User of this address or owner"
		);
		uint256 timeLockedAmount = devPoolLockedWallet.releaseClaimable(
			devPoolReleaseRate()
		);

		_balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
	}

	////////////////////////////////////////////////
	// Strategic Partner LOCKED WALLET

	function unlockStrategicPartnerWallet() public {
		require(
			strategic_partner_address ==
				strategicPartnerLockedWallet.beneficiary() ||
				msg.sender == this.getOwner(),
			"TokenTimeLock: Only claimable by User of this address or owner"
		);
		uint256 timeLockedAmount = strategicPartnerLockedWallet
			.releaseClaimable(strategicPartnerReleaseRate());

		_balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
	}

	////////////////////////////////////////////////
	// Private Placement LOCKED WALLET

	function privatePlacementAmount() public view returns (uint256) {
		return privatePlacementLockedWallet._getAmount(msg.sender);
	}

	function privatePlacementIndex() public view returns (uint256) {
		return privatePlacementLockedWallet._getIndex(msg.sender);
	}

	function privatePlacementMonth() public view returns (uint256) {
		return privatePlacementLockedWallet._getMonth(msg.sender);
	}

	function privatePlacementDuration() public view returns (uint256) {
		return privatePlacementLockedWallet._getDuration(msg.sender);
	}

	function addPrivatePlacementUser(address user_, uint256 amount_)
		public
		onlyOwner
	{
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot add empty user"
		);
		require(amount_ > 0, "MultiTokenTimeLock: Cannot use zero amount");

		privatePlacementLockedWallet._lockWallet(amount_, user_);
	}

	function deletePrivatePlacementUser(address user_) public onlyOwner {
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot delete empty user"
		);

		privatePlacementLockedWallet.deleteUser(user_);
	}

	function releasePrivatePlacement() public {
		uint256 releasedClaimableLockedAmount = privatePlacementLockedWallet
			.releaseClaimable(privatePlacementReleaseRate(), msg.sender);

		_balances[_msgSender()] = _balances[_msgSender()].add(
			releasedClaimableLockedAmount
		);
	}

	////////////////////////////////////////////////
	// Team and Project Coordinator LOCKED WALLET
	function addTeamAndProjectCoordinatorUser(address user_, uint256 amount_)
		private
		onlyOwner
	{
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot add empty user"
		);
		require(amount_ > 0, "MultiTokenTimeLock: Cannot use zero amount");

		teamAndProjectCoordinatorLockedWallet._lockWallet(amount_, user_);
	}

	function deleteTeamAndProjectCoordinator(address user_) public onlyOwner {
		require(
			user_ != address(0),
			"MultiTokenTimeLock: Cannot delete empty user"
		);

		teamAndProjectCoordinatorLockedWallet.deleteUser(user_);
	}

	function releaseTeamAndProjectCoordinator() public {
		uint256 releasedClaimableLockedAmount = teamAndProjectCoordinatorLockedWallet
				.releaseClaimable(
					teamAndProjectCoordinatorReleaseRate(),
					msg.sender
				);

		_balances[_msgSender()] = _balances[_msgSender()].add(
			releasedClaimableLockedAmount
		);
	}
}
