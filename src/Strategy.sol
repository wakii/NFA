// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";
import {IStETH} from "./interfaces/IStETH.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SwapModuleLib} from "./SwapModuleLib.sol";


contract Strategy is IStrategy, Ownable {
    using SafeERC20 for IERC20;

    ISwapRouter public router;
    address public factory;
    address public immutable asset;
    address public immutable want;
    address public vault;
    // uint24 public constant POOL_FEE = 3000;

    event SetVault(address vault);
    event SetSwapModuleInfo(address router, address factory);

    constructor(address vault_, address underlyingAsset_, address want_, address defaultRouter_, address factory_) {
        vault = vault_;
        asset = underlyingAsset_;
        want = want_;
        factory = factory_;
        IERC20(asset).approve(defaultRouter_, type(uint256).max);
        IERC20(want).approve(defaultRouter_, type(uint256).max);
        router = ISwapRouter(defaultRouter_);
    }

    function totalAssets() public view returns (uint256 amounts){
        return balanceOfUnderlying() + balanceOfPool();
    }

    function balanceOfUnderlying() public view returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint) {
        return SwapModuleLib.estimateAmountOut(factory, want, asset, IERC20(want).balanceOf(address(this)));
    }

    function setVault(address vault_) external onlyOwner {
        vault = vault_;
        emit SetVault(vault_);
    }
    
    function setSwapModuleInfo(address router_, address factory_) external onlyOwner {
        require(router_ != address(0x0), "Invalid Address");
        require(factory_ != address(0x0), "Invalid Address");
        router = ISwapRouter(router_);
        factory = factory_;
        IERC20(asset).approve(router, type(uint256).max);
        IERC20(want).approve(router, type(uint256).max);
        emit SetSwapModuleInfo(router_, factory_);
    }

    function deposit() external {
        _swap();
    }

    ///@dev When underlying asset(float) is not enough to cover debt for withdrawal, 
    ///     Restore underlying asset tokens (by re-swap want into asset) 
    ///     Include the extra avilable(0.5%) for slippage in coverting want into asset.
    function withdraw(uint256 amountDebt) external {
        require(msg.sender == vault, "Unauthorized Caller : Vault");
        uint256 currentUnderlying = balanceOfUnderlying();

        if(amountDebt > currentUnderlying) {
            uint256 lastAmountInWithExtra = _estimateAmountIn(asset, want, amountDebt)  * (1000 + 5)/ 1000;
            uint256 amountIn = 
                lastAmountInWithExtra > IERC20(want).balanceOf(address(this)) ? 
                 _swapExactInput(want, asset, IERC20(want).balanceOf(address(this))) :
                 _swapExactOutput(asset, want, lastAmountInWithExtra);
            if(amountDebt > amountIn) {
                uint256 loss = amountDebt - amountIn; // TODO Report LOSS 
                amountDebt -= loss;
            }
        }
        if(amountDebt > 0) IERC20(asset).safeTransfer(msg.sender, amountDebt);
    }

    ///@notice Calculate the amount of tokenOut with amountIn of tokenIn
    function _estimateAmountOut(address tokenIn, address tokenOut, uint256 amountIn) internal view returns(uint256 amountOut) {
        return SwapModuleLib.estimateAmountOut(factory, tokenIn, tokenOut, amountIn);
    }
    
    ///@notice Calculate the amount of tokenIn needed to get amountOut of tokenOut
    function _estimateAmountIn(address tokenIn, address tokenOut, uint256 amountOut) internal view returns(uint256 amountIn) {
        return SwapModuleLib.estimateAmountIn(factory, tokenIn, tokenOut, amountOut);
    }

    function _swap() internal {
        uint amountIn = IERC20(asset).balanceOf(address(this));
        uint256 lastAmountOut = SwapModuleLib.estimateAmountOut(factory, asset, want, 10000);
        uint256 amountOut = _swapExactInput(asset, want, amountIn);
        require(lastAmountOut * (1000 - 5) / 1000 < amountOut, "TOO MUCH SLIPPAGE");
    }

    function _swapExactInput(address tokenIn, address tokenOut, uint256 amountIn) internal returns(uint256 amountOut) {
        amountOut = SwapModuleLib.swapExactInput(address(router), tokenIn, tokenOut, amountIn);
    }

    function _swapExactOutput(address tokenIn, address tokenOut, uint256 amountOut) internal returns(uint256 amountIn) {
        amountIn = SwapModuleLib.swapExactOutput(address(router), tokenIn, tokenOut, amountOut);
    }
}
