// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";

/**
 * @title Vault
 * @author Wakii
 */
contract Vault is IVault, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public immutable asset;
    address public strategy;

    constructor(
        address asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        asset = asset_;
    }


    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() public view override returns(uint256 totalManagedAssets) {
        // return IERC20(asset).balanceOf(address(this)) + IStrategy(strategy).totalAssets();
        return IERC20(asset).balanceOf(address(this)); // TODO add Strategy want balance;
     }

    function convertToShares(uint256 assets) external view override returns (uint256 shares) {
    }

    function convertToAssets(uint256 shares) external view override returns (uint256 assets) {}

    function maxDeposit(address receiver) external pure override returns (uint256 maxAssets) {
        return type(uint256).max; // TODO IF whiltelist max, ELSE 0
    }

    function previewDeposit(uint256 assets) public view override returns (uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : assets * supply / totalAssets();
    }

    function deposit(uint256 assets, address receiver) external override nonReentrant returns (uint256 shares) {
        require((shares = previewDeposit(assets)) > 0, "NOT ENOUGH ASSETS");
        IERC20(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function maxMint(address receiver) public pure override returns (uint256 maxShares){
        return type(uint256).max; // TODO IF whiltelist max, ELSE 0
    }

    function previewMint(uint256 shares) public view returns (uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : shares / supply * totalAssets();
    }

    function mint(uint256 shares, address receiver) external returns (uint256 assets) {
        require(shares <= maxMint(receiver), "OVER MINT");
        require((assets = previewMint(shares))> 0, "NOT ENOUGH SHARES");
        IERC20(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function maxWithdraw(address owner) external view returns (uint256 maxAssets) {

    } 

    function previewWithdraw(uint256 assets) external view returns (uint256 shares) {}

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external override nonReentrant returns (uint256 shares) {}

    function maxRedeem(address owner) external view returns (uint256 maxShares) {}

    function previewRedeem(uint256 shares) external view returns (uint256 assets) {
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets) {}
}
