// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Lockable.sol";
import "./Stakable.sol";

contract TalaxToken is ERC20, ERC20Burnable, Ownable, Stakable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(uint256 => uint256) internal _stakingPackage;
    uint256 public _stakingReward;
    bool public _airdropStatus;

    uint16 public _taxFee;

    /**
     * Addresses
     */

    address private timelockController;

    /**
     * Local (in this smart contract)
     * address staking_reward_address;
     * address liquidity_reserve_address;
     */

    address private public_sale_address;
    address private private_sale_address;
    address private private_placement_address;
    address private dev_pool_address_1;
    address private dev_pool_address_2;
    address private dev_pool_address_3;
    address private strategic_partner_address_1;
    address private strategic_partner_address_2;
    address private strategic_partner_address_3;
    address private team_and_project_coordinator_address_1;
    address private team_and_project_coordinator_address_2;
    address private team_and_project_coordinator_address_3;

    /**
     * Lockable Object
     */
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

    constructor() ERC20("TALAXEUM", "TALAX") {
        _totalSupply = 210 * 1e6 * 1e18;
        _name = "TALAXEUM";
        _symbol = "TALAX";

        // later divided by 100 to make percentage
        _taxFee = 1;

        _airdropStatus = true;

        // in percentage
        _stakingPackage[30 days] = 5;
        _stakingPackage[90 days] = 6;
        _stakingPackage[180 days] = 7;
        _stakingPackage[365 days] = 8;

        // testing purposes
        _balances[msg.sender] = 10 * 1e6 * 1e18;

        /**
         * Addresses initialization
         */

        public_sale_address = 0x5470c8FF25EC05980fc7C2967D076B8012298fE7;
        private_sale_address = 0x75837E79215250C45331b92c35B7Be506eD015AC;
        private_placement_address = 0x07A20dc6722563783e44BA8EDCA08c774621125E;
        dev_pool_address_1 = 0xf09f65dD4D229E991901669Ad7c7549f060E30b9;
        dev_pool_address_2 = 0x1A2118E056D6aF192E233C2c9CFB34e067DED1F8;
        dev_pool_address_3 = 0x126974fa373267d86fAB6d6871Afe62ccB68e810;
        strategic_partner_address_1 = 0x2F838cF0Df38b2E91E747a01ddAE5EBad5558b7A;
        strategic_partner_address_2 = 0x45094071c4DAaf6A9a73B0a0f095a2b138bd8A3A;
        strategic_partner_address_3 = 0xAeB26fB84d0E2b3B353Cd50f0A29FD40C916d2Ab;
        // team_and_project_coordinator_address_1 = 0x84435c6FD8de0E75D6b3dC108F4345344a91a268; //for testing only
        team_and_project_coordinator_address_1 = 0xE61E7a7D16db384433E532fB85724e7f3BdAaE2F;
        team_and_project_coordinator_address_2 = 0x406605Eb24A97A2D61b516d8d850F2aeFA6A731a;
        team_and_project_coordinator_address_3 = 0x97620dEAdC98bC8173303686037ce7B986CF53C3;

        /**
         * Amount Initialization
         */

        _stakingReward = 17514 * 1e3 * 1e18;
        _balances[address(this)] = 52500 * 1e3 * 1e18;

        // Public Sale
        _balances[0x5470c8FF25EC05980fc7C2967D076B8012298fE7] = 42 * 1e6 * 1e18;

        // Private Sale
        _balances[0x75837E79215250C45331b92c35B7Be506eD015AC] =
            6993 *
            1e3 *
            1e18;

        //Public Sale, Private Sale, Private Placement, Staking Reward
        _totalSupply = _totalSupply.sub(
            73500 * 1e3 * 1e18,
            "TalaxToken: Cannot transfer more than total supply"
        );

        /**
         * Locked Wallet Initialization
         */

        privatePlacementLockedWallet = new Lockable(
            6993 * 1e3 * 1e18,
            private_placement_address
        );

        devPoolLockedWallet_1 = new Lockable(
            14 * 1e6 * 1e18,
            dev_pool_address_1
        );
        devPoolLockedWallet_2 = new Lockable(
            14 * 1e6 * 1e18,
            dev_pool_address_2
        );
        devPoolLockedWallet_3 = new Lockable(
            14 * 1e6 * 1e18,
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

        // Dev Pool, Strategic Partner, Team and Project Coordinator
        _totalSupply = _totalSupply.sub(
            84000 * 1e3 * 1e18,
            "TalaxToken: Cannot transfer more than total supply"
        );

        // This timelockcontroller address is still in Rinkeby network since we were considering using openzeppelin services
        timelockController = 0x267dbc62F9f431107FB968aC5dEA7fBa6F0B0514;
        transferOwnership(timelockController);
    }

    fallback() external payable {
        _addThirdOfValue(msg.value);
    }

    receive() external payable {
        _addThirdOfValue(msg.value);
    }

    /**
     * @notice EVENTS
     */

    event ChangeTax(address indexed who, uint256 amount);
    event ChangeAirdropStatus(address indexed who, bool status);

    event AddPrivatePlacement(address indexed from, address indexed who);
    event DeletePrivatePlacement(address indexed from, address indexed who);

    event AddStrategicPartner(address indexed from, address indexed who);
    event DeleteStrategicPartner(address indexed from, address indexed who);

    /**
     * @notice MODIFIERS
     */

    modifier checkAirdropStatus() {
        require(_airdropStatus == true, "TalaxToken: Airdrop is not available");
        _;
    }

    /**
     * @notice ACCESSORS
     */

    /**
     * @dev See address of this smart contract.
     */
    function thisAddress() external view returns (address) {
        return address(this);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the tax fee.
     */
    function taxFee() external view returns (uint256) {
        return _taxFee;
    }

    /**
     * @notice INTERNAL FUNCTIONS
     */

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev this is the release rate for partial token release
     */
    function privatePlacementReleaseAmount()
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

    function devPoolReleaseAmount() internal pure returns (uint256[43] memory) {
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

    function devPoolReleaseAmountAlternate()
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

    function strategicPartnerReleaseAmount()
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

    function strategicPartnerReleaseAmountAlternate()
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

    function teamAndProjectCoordinatorReleaseAmount()
        internal
        pure
        returns (uint256[43] memory)
    {
        return [
            SafeMath.mul(1166667, 1e18),
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

    function teamAndProjectCoordinatorReleaseAmountAlternate()
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
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "TalaxToken: from zero address");
        require(to != address(0), "TalaxToken: to zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "TalaxToken: transfer amount exceeds balance"
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

        _balances[from] = _balances[from].sub(
            amount,
            "TalaxToken: transfer exceeds balance"
        );
        _balances[to] = _balances[to].add(taxedAmount);
        emit Transfer(from, to, taxedAmount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mintLiquidityReserve(uint256 amount_) internal {
        _balances[address(this)] = _balances[address(this)].add(amount_);
        _totalSupply = _totalSupply.add(amount_);
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
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
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

        _afterTokenTransfer(account, address(0), amount);
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

    function liquidityReserveBalance() external view returns (uint256) {
        return this.balanceOf(address(this));
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
    }

    function mintLiquidityReserve(uint256 amount_) public onlyOwner {
        require(amount_ > 0, "Amount mint cannot be 0");
        _mintLiquidityReserve(amount_);
    }

    function burnStakingReward(uint256 amount_) external onlyOwner {
        require(
            amount_ < _stakingReward,
            "TalaxToken: Amount burnt larger than Staking Reward"
        );
        _stakingReward = _stakingReward.sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
    }

    function changeTaxFee(uint16 taxFee_) external onlyOwner {
        _taxFee = taxFee_;
        emit ChangeTax(msg.sender, taxFee_);
    }

    function changeAirdropStatus(bool status_) external onlyOwner {
        _airdropStatus = status_;
        emit ChangeAirdropStatus(msg.sender, status_);
    }

    function changePenaltyFee(uint256 penaltyFee_) external onlyOwner {
        _changePenaltyFee(penaltyFee_);
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
            "TalaxToken: Staking option not exist"
        );
        require(
            _amount < _balances[_msgSender()],
            "TalaxToken: Cannot stake more than balance"
        );

        _stake(_amount, _stakePeriod, _stakingPackage[_stakePeriod]);
        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);
        // Stake amount goes to liquidity reserve
        _balances[address(this)] = _balances[address(this)].add(_amount);
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
        _mintLiquidityReserve(reward_);
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
        _mintLiquidityReserve(reward_);
        _balances[address(this)] = _balances[address(this)].sub(amount_);
        _balances[address(this)] = _balances[address(this)].sub(reward_);
        _totalSupply += amount_ + reward_;
        _balances[_msgSender()] += amount_ + reward_;
    }

    function claimAirdrop() external checkAirdropStatus {
        uint256 airdrop = _claimAirdrop(msg.sender);
        _balances[address(this)] = _balances[address(this)].sub(airdrop);
        _balances[msg.sender] = _balances[msg.sender].add(airdrop);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockPrivatePlacementWallet() external {
        require(
            msg.sender == privatePlacementLockedWallet.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );

        uint256 timeLockedAmount = privatePlacementLockedWallet
            .releaseClaimable(privatePlacementReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Dev Pool Locked Wallet
     */
    function unlockDevPoolWallet_1() external {
        require(
            msg.sender == devPoolLockedWallet_1.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_1.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_2() external {
        require(
            msg.sender == devPoolLockedWallet_2.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_2.releaseClaimable(
            devPoolReleaseAmount()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockDevPoolWallet_3() external {
        require(
            msg.sender == devPoolLockedWallet_3.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = devPoolLockedWallet_3.releaseClaimable(
            devPoolReleaseAmountAlternate()
        );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockStrategicPartnerWallet_1() external {
        require(
            msg.sender == strategicPartnerLockedWallet_1.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_1
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_2() external {
        require(
            msg.sender == strategicPartnerLockedWallet_2.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_2
            .releaseClaimable(strategicPartnerReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockStrategicPartnerWallet_3() external {
        require(
            msg.sender == strategicPartnerLockedWallet_3.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = strategicPartnerLockedWallet_3
            .releaseClaimable(strategicPartnerReleaseAmountAlternate());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    /**
     * @dev LockedWallet: Team And Project Coordinator Locked Wallet
     */
    function unlockTeamAndProjectCoordinatorWallet_1() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_1.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_1
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_2() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_2.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_2
            .releaseClaimable(teamAndProjectCoordinatorReleaseAmount());

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function unlockTeamAndProjectCoordinatorWallet_3() external {
        require(
            msg.sender == teamAndProjectCoordinatorLockedWallet_3.beneficiary(),
            "TalaxToken: Wallet Owner Only"
        );
        uint256 timeLockedAmount = teamAndProjectCoordinatorLockedWallet_3
            .releaseClaimable(
                teamAndProjectCoordinatorReleaseAmountAlternate()
            );

        _balances[_msgSender()] = _balances[_msgSender()].add(timeLockedAmount);
    }

    function testCalculateDuration(address user, uint256 index)
        public
        view
        returns (uint256)
    {
        return _testCalculateDuration(user, index);
    }

    function blockTime() public view returns (uint256) {
        return _blockTime();
    }
}
