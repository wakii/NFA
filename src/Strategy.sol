// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import {IStrategy} from "./interfaces/IStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract WSTETHStrategy is IStrategy {
    ISwapRouter public router;
    IERC20 private immutable _asset;
    IERC20 private immutable _want;
    uint24 public constant poolFee = 3000;

    constructor(address underlyingAsset_, address want_) {
        _asset = IERC20(underlyingAsset_);
        _want = IERC20(want_);
        _asset.approve(address(router), type(uint256).max);

    }

    function totalAssets() public view returns (uint256 totalAssets){}

    function updateRouterAddress(address router_) external {
        router = ISwapRouter(router_);
    }

    // function swapExactInput(uint256 amountIn) public returns (uint amountOut) {
    //     ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
    //         tokenIn: address(_asset),
    //         tokenOut: address(_want),
    //         fee: poolFee,
    //         recipient: address(this),
    //         deadline: block.timestamp,
    //         amountIn: amountIn,
    //         amountOutMinimum: 0,
    //     })
    // }
}
