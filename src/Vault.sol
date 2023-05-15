// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "openzeppelin-contracts/interfaces/IERC4626.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract Vault is IERC4626, ERC20 {
    IERC20 public immutable _asset;

    constructor(
        address asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = IERC20(asset_);
    }

    function asset() external view override returns (address assetTokenAddress) {
        return address(_asset);
    }

    function totalAssets() external view override returns(uint256 totalManagedAssets) {}

    function convertToShares(uint256 assets) external view override returns (uint256 shares) {}

    function convertToAssets(uint256 shares) external view override returns (uint256 assets) {}

    function maxDeposit(address receiver) external view override returns (uint256 maxAssets) {}

    function previewDeposit(uint256 assets) external view override returns (uint256 shares) {}

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {}

    function maxMint(address receiver) external view override returns (uint256 maxShares){}

    function previewMint(uint256 shares) external view returns (uint256 assets) {}

    function mint(uint256 shares, address receiver) external returns (uint256 assets) {}

    function maxWithdraw(address owner) external view returns (uint256 maxAssets) {} 

    function previewWithdraw(uint256 assets) external view returns (uint256 shares) {}

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares) {}

    function maxRedeem(address owner) external view returns (uint256 maxShares) {}

    function previewRedeem(uint256 shares) external view returns (uint256 assets) {}

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets) {}
}
