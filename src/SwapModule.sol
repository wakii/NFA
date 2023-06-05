// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';


contract SwapModule {
    IUniswapV3Factory public swapFactory;
    ISwapRouter public router;
    uint256 public fee = 3000;

    constructor(address factory_) {
        swapFactory = IUniswapV3Factory(factory_);
    }

    function estimateAmountOut(address tokenIn, address tokenOut, uint256 amountIn) public view returns(uint256 amountOut) {
        if(amountIn == 0) return 0;

        address pool = swapFactory.getPool(tokenIn, tokenOut, fee);
        require(pool != address(0), "POOL NOT EXISTS");

        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo=10);
        amountOut = OracleLibary.getQuoteAtTick(
            tick,
            amountIn,
            tokenIn,
            tokenOut
            );
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