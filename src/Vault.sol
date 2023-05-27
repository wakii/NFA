// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";

/**
 * @title Vault
 * @author Wakii
 */
contract Vault is IVault, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    IERC20 private immutable _asset;
    address public strategy;

    constructor(
        address asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = IERC20(asset_);
    }


    function asset() public view override returns (address) {
        return address(_asset);
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
        return _asset.balanceOf(address(this)); // TODO add Strategy want balance;
     }

    function convertToShares(uint256 assets) public view override returns (uint256 shares) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    function convertToAssets(uint256 shares) public view override returns (uint256 assets) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    function maxDeposit(address receiver) public pure override returns (uint256 maxAssets) {
        return type(uint256).max; // TODO IF whiltelist max, ELSE 0
    }

    function maxMint(address receiver) public pure override returns (uint256 maxShares){
        return type(uint256).max; // TODO IF whiltelist max, ELSE 0
    }

    function maxWithdraw(address owner) public view returns (uint256 maxAssets) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Down);
    } 

    function maxRedeem(address owner) public view returns (uint256 maxShares) {
        return balanceOf(owner);
    }
    
    function previewDeposit(uint256 assets) public view override returns (uint256 shares) {
        return _convertToShares(assets, Math.Rounding.Down);
    }

    function previewMint(uint256 shares) public view returns (uint256 assets) {
        return _convertToAssets(shares, Math.Rounding.Up);
    }

    function previewWithdraw(uint256 assets) public view returns (uint256 shares) {
        return _convertToShares(assets, Math.Rounding.Up);
    }

    function previewRedeem(uint256 shares) public view returns (uint256 assets) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }

    function deposit(uint256 assets, address receiver) public override nonReentrant returns (uint256 shares) {
        require(assets <= maxDeposit(receiver), "DEPOSIT OVER MAX");
        require((shares = previewDeposit(assets)) > 0, "NOT ENOUGH ASSETS");
        _deposit(_msgSender(), receiver, assets, shares);
    }

    function mint(uint256 shares, address receiver) public returns (uint256 assets) {
        require(shares <= maxMint(receiver), "OVER MINT");
        require((assets = previewMint(shares)) > 0, "NOT ENOUGH SHARES");
        _deposit(_msgSender(), receiver, assets, shares);
    }


    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override nonReentrant returns (uint256 shares) {
        require(assets <= maxWithdraw(owner), "OVER WITHDRAW");
        require((shares = previewWithdraw(assets)) > 0, "TOO LOW WITHDRAWAL");
        _withdraw(_msgSender(), receiver, owner, assets, shares);
    }


    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public returns (uint256 assets) {
        require(shares <= maxRedeem(owner), "OVER REDEEM");
        require((assets = previewRedeem(shares)) > 0, "TOO LOW REDEEM");
        _withdraw(_msgSender(), receiver, owner, assets, shares);
    }

    /////////////////////////////////////
    ////////// INTERNAL /////////////////
    /////////////////////////////////////

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view returns(uint256 shares) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : assets.mulDiv(supply, totalAssets(), rounding);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view returns(uint256 assets) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : shares.mulDiv(totalAssets(), supply, rounding);
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal {
        _asset.safeTransferFrom(caller, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares) internal {
        if(caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        // TODO  Float check, and  withdraw from strategy
        // if (assets > float) {
        //  
        // } else {
        // 
        // }
        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }
}
