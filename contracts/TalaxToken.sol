// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./src/Context.sol";
import "./src/IBEP20.sol";
import "./src/Multiownable.sol";
import "./src/SafeMath.sol";
import "./Lockable.sol";
import "./Stakable.sol";

contract TalaxToken is Context, IBEP20, Multiownable, Stakable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => uint256) private _stakingPackage;

    uint16 public _taxFee;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    /**
     * Balances
     */
    uint256 private _stakingReward;

    uint256 private _devPool;
    uint256 private _teamAndProjectCoordinator;

    uint256 private _privatePlacement;
    uint256 private _strategicPartner;

    /**
     * Addresses
     */
    address public_sale_address;

    address private_sale_address;
    address private_placement_address;

    /**
     * Local
     * address staking_reward_address;
     * address liquidity_reserve_address;
     */

    address dev_pool_address_1;
    address dev_pool_address_2;
    address dev_pool_address_3;

    address strategic_partner_address_1;
    address strategic_partner_address_2;
    address strategic_partner_address_3;

    address team_and_project_coordinator_address_1;
    address team_and_project_coordinator_address_2;
    address team_and_project_coordinator_address_3;

    /**
     * Lockable Object
     */
    Lockable public privatePlacementLockedWallet;

    Lockable public devPoolLockedWallet_1;
    Lockable public devPoolLockedWallet_2;
    Lockable public devPoolLockedWallet_3;
    Lockable public strategicPartnerLockedWallet_1;
    Lockable public strategicPartnerLockedWallet_2;
    Lockable public strategicPartnerLockedWallet_3;
    Lockable public teamAndProjectCoordinatorLockedWallet_1;
    Lockable public teamAndProjectCoordinatorLockedWallet_2;
    Lockable public teamAndProjectCoordinatorLockedWallet_3;

    constructor() {
        _name = "TALAXEUM";
        _symbol = "TALAX";
        _decimals = 18;
        _totalSupply = 210 * 1e6 * 10**18;

        /**
         * Addresses initialization
         */

        // public_sale_address = [ADDRESS];
        // private_sale_address = [ADDRESS];

        // dev_pool_address_1 = [ADDRESS];
        // dev_pool_address_2 = [ADDRESS];
        // dev_pool_address_3 = [ADDRESS];
        // dev_pool_address = 0x0Fa15f7550eC226C2a963f9cEB18aed8FD182075;

        //strategic_partner_address_1 = [ADDRESS]
        //strategic_partner_address_2 = [ADDRESS]
        //strategic_partner_address_3 = [ADDRESS]

        //team_and_project_coordinator_address_1 = [ADDRESS]
        //team_and_project_coordinator_address_2 = [ADDRESS]
        //team_and_project_coordinator_address_3 = [ADDRESS]

        /**
         * Amount Initialization
         */

        _stakingReward = 17514 * 1e3 * 10**18;
        _balances[address(this)] = 52500 * 1e3 * 10**18;

        _balances[public_sale_address] = 42 * 1e6 * 10**18;
        _balances[private_sale_address] = 6993 * 1e3 * 10**18;

        //Public Sale
        _totalSupply = _totalSupply.sub(
            42 * 1e6 * 10**18,
            "TalaxToken: Cannot transfer more than total supply"
        );
        //Private Sale
        _totalSupply = _totalSupply.sub(
            6993 * 1e3 * 10**18,
            "TalaxToken: Cannot transfer more than total supply"
        );

        _totalSupply = _totalSupply.sub(
            _stakingReward,
            "TalaxToken: Cannot transfer more than total supply"
        );

        /**
         * Locked Wallet Initialization
         */

        privatePlacementLockedWallet = new Lockable(
            6993 * 1e3 * 10**18,
            private_placement_address
        );

        devPoolLockedWallet_1 = new Lockable(
            14 * 1e6 * 10**18,
            dev_pool_address_1
        );
        devPoolLockedWallet_2 = new Lockable(
            14 * 1e6 * 10**18,
            dev_pool_address_2
        );
        devPoolLockedWallet_3 = new Lockable(
            14 * 1e6 * 10**18,
            dev_pool_address_3
        );

        // teamAndProjectCoordinatorLockedWallet_1 = new Lockable(
        //     10500 * 1e3 * 10**18,
        //     team_and_project_coordinator_address_1
        // );
        // teamAndProjectCoordinatorLockedWallet_2 = new Lockable(
        //     10500 * 1e3 * 10**18,
        //     team_and_project_coordinator_address_2
        // );
        // teamAndProjectCoordinatorLockedWallet_3 = new Lockable(
        //     10500 * 1e3 * 10**18,
        //     team_and_project_coordinator_address_3
        // );

        // strategicPartnerLockedWallet_1 = new Lockable(
        //     3500 * 1e3 * 10**18,
        //     strategic_partner_address_1
        // );
        // strategicPartnerLockedWallet_2 = new Lockable(
        //     3500 * 1e3 * 10**18,
        //     strategic_partner_address_2
        // );
        // strategicPartnerLockedWallet_3 = new Lockable(
        //     3500 * 1e3 * 10**18,
        //     strategic_partner_address_3
        // );

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
        uint256 thirdOfValue = SafeMath.div(msg.value, 3);
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

    receive() external payable {
        uint256 thirdOfValue = SafeMath.div(msg.value, 3);
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

    event ChangeTax(address indexed who, uint256 amount);

    event AddPrivatePlacement(address indexed from, address indexed who);
    event DeletePrivatePlacement(address indexed from, address indexed who);

    event AddStrategicPartner(address indexed from, address indexed who);
    event DeleteStrategicPartner(address indexed from, address indexed who);

    /**
    * @notice INTERNAL FUNCTIONS
    */

    /**
     * @dev this is the release rate for partial token release
     */
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

    function devPoolReleaseRate() internal pure returns (uint256[43] memory) {
        return [
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18)
        ];
    }

    function devPoolReleaseRateAlternate()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(1 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18)
        ];
    }

    function strategicPartnerReleaseRate()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(333333, 1e18),
            0,
            0,
            0,
            SafeMath.mul(333333, 1e18),
            0,
            0,
            SafeMath.mul(333333, 1e18),
            0,
            0,
            SafeMath.mul(333333, 1e18),
            0,
            0,
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18),
            SafeMath.mul(72222, 1e18)
        ];
    }

    function strategicPartnerReleaseRateAlternate()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(333334, 1e18),
            0,
            0,
            0,
            SafeMath.mul(333334, 1e18),
            0,
            0,
            SafeMath.mul(333334, 1e18),
            0,
            0,
            SafeMath.mul(333334, 1e18),
            0,
            0,
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18),
            SafeMath.mul(72223, 1e18)
        ];
    }

    function teamAndProjectCoordinatorReleaseRate()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(1166667, 1e18),
            0,
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
            SafeMath.mul(333333, 1e18),
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

    function teamAndProjectCoordinatorReleaseRateAlternate()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(1166666, 1e18),
            0,
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(10 * 1e6, 1e18),
            0,
            0,
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
            SafeMath.mul(333334, 1e18),
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
        require(
            sender != address(0),
            "TalaxToken: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "TalaxToken: transfer to the zero address"
        );

        uint256 tax = SafeMath.div(SafeMath.mul(amount, _taxFee), 100);
        uint256 taxedAmount = SafeMath.sub(amount, tax);

        uint256 teamFeeOfThird = SafeMath.div(
            (SafeMath.mul(taxedAmount, SafeMath.div(2, 10))),
            3
        );
        uint256 liquidityFee = SafeMath.mul(taxedAmount, SafeMath.div(8, 10));

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
        require(
            account != address(0),
            "TalaxToken: burn from the zero address"
        );

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
        require(
            owner != address(0),
            "TalaxToken: approve from the zero address"
        );
        require(
            spender != address(0),
            "TalaxToken: approve to the zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * @notice EXTERNAL FUNCTIONS
    */

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address[] memory) {
        return getAllOwners();
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

    function blockTime() external view returns (uint256) {
        return block.timestamp;
    }

    function stakingRewardAmount() external view returns (uint256) {
        return _stakingReward;
    }

    function liquidityReserveBalance() external view returns (uint256) {
        return this.balanceOf(address(this));
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

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) external onlyAllOwners {
        _mint(_msgSender(), amount);
    }

    function mintStakingReward(uint256 amount_) external onlyAllOwners {
        require(amount_ != 0, "Amount mint cannot be 0");
        _stakingReward = _stakingReward.add(amount_);
        _totalSupply = _totalSupply.add(amount_);
    }

    function mintLiquidityReserve(uint256 amount_) public onlyAllOwners {
        require(amount_ != 0, "Amount mint cannot be 0");
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
    }
    
    function burnStakingReward(uint256 amount_) external onlyAllOwners {
        require(
            amount_ < _stakingReward,
            "TalaxToken: Amount burnt cannot be larger than Staking Reward"
        );
        _stakingReward = _stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
    }

    function changeTaxFee(uint16 taxFee_) external onlyAllOwners {
        _taxFee = taxFee_;
        emit ChangeTax(msg.sender, taxFee_);
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
        _balances[address(this)].add(_amount);
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
        _balances[address(this)].sub(amount_);
        _balances[address(this)].sub(reward_);
        _mint(_msgSender(), amount_ + reward_);
    }

    function withdrawAllStake(uint256 stake_index) external {
        (uint256 amount_, uint256 reward_) = _withdrawAllStake(stake_index);
        // Return staked tokens to user
        // Amount staked on liquidity reserved goes to the user
        // Staking reward, calculated from Stakable.sol, is minted and substracted
        mintLiquidityReserve(reward_);
        _balances[address(this)].sub(amount_);
        _balances[address(this)].sub(reward_);
        _mint(_msgSender(), amount_ + reward_);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockPrivatePlacementWallet() external {
        require(
            private_placement_address ==
                privatePlacementLockedWallet.beneficiary(),
            "TalaxToken: Only claimable by User of this address or owner"
        );
        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseRate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Dev Pool Locked Wallet
     */
    function unlockDevPoolWallet_1() external {
        require(
            msg.sender == devPoolLockedWallet_1.beneficiary(),
            "TalaxToken: Only claimable by User of this address or owner"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_1.releaseClaimable(
            devPoolReleaseRate()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_2() external {
        require(
            msg.sender == devPoolLockedWallet_2.beneficiary(),
            "TalaxToken: Only claimable by User of this address or owner"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_2.releaseClaimable(
            devPoolReleaseRate()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_3() external {
        require(
            msg.sender == devPoolLockedWallet_3.beneficiary(),
            "TalaxToken: Only claimable by User of this address or owner"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_3.releaseClaimable(
            devPoolReleaseRateAlternate()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockStrategicPartnerWallet_1() external {
        require(
            msg.sender == strategicPartnerLockedWallet_1.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_1
            .releaseClaimable(strategicPartnerReleaseRate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_2() external {
        require(
            msg.sender == strategicPartnerLockedWallet_2.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_2
            .releaseClaimable(strategicPartnerReleaseRate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_3() external {
        require(
            msg.sender == strategicPartnerLockedWallet_3.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_3
            .releaseClaimable(strategicPartnerReleaseRateAlternate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockTeamAndProjectCoordinatorWallet_1() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_1.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
            .releaseClaimable(teamAndProjectCoordinatorReleaseRate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_2() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_2.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
            .releaseClaimable(teamAndProjectCoordinatorReleaseRate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_3() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_3.beneficiary(),
            "TalaxToken: Only claimable by User of this address"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
            .releaseClaimable(teamAndProjectCoordinatorReleaseRateAlternate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }
}
