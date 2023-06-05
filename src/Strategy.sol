// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;
// import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

// contract WSTETHStrategy is IStrategy {
//     ISwapRouter public router;
//     IERC20 private immutable _asset;
//     IERC20 private immutable _want;
//     uint24 public constant poolFee = 3000;

//     constructor(address underlyingAsset_, address want_) {
//         _asset = IERC20(underlyingAsset_);
//         _want = IERC20(want_);
//         _asset.approve(address(router), type(uint256).max);

//     }

//     function updateRouterAddress(address router_) {
//         router = router_;
//     }

//     // function swapExactInput(uint256 amountIn) public returns (uint amountOut) {
//     //     ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
//     //         tokenIn: address(_asset),
//     //         tokenOut: address(_want),
//     //         fee: poolFee,
//     //         recipient: address(this),
//     //         deadline: block.timestamp,
//     //         amountIn: amountIn,
//     //         amountOutMinimum: 0,
//     //     })
//     // }
// }
