// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';


contract SwapModule {
    IUniswapV3Factory public swapFactory;
    ISwapRouter public router;
    uint24 public fee = 3000;

    constructor(address factory_, address router_) {
        swapFactory = IUniswapV3Factory(factory_);
        router = ISwapRouter(router_);
    }

    function estimateAmountOut(address tokenIn, address tokenOut, uint256 amountIn) public view returns(uint256 amountOut) {
        if(amountIn == 0) return 0;

        address pool = swapFactory.getPool(tokenIn, tokenOut, fee);
        require(pool != address(0), "POOL NOT EXISTS");

        (int24 tick, ) = OracleLibrary.consult(pool, 10); // 10 seconds ago
        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            uint128(amountIn), // casting 
            tokenIn,
            tokenOut
            );
    }   

    function swapExactInput(address tokenIn_, address tokenOut_, uint256 amountIn_, address receiver_) public returns (uint amountOut) {
        uint lastTokenOut = estimateAmountOut(tokenIn_, tokenOut_, amountIn_);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn_,
            tokenOut: tokenOut_,
            fee: fee,
            recipient: receiver_,
            deadline: block.timestamp,
            amountIn: amountIn_,
            amountOutMinimum: lastTokenOut * (1000 - 5) / 1000, // 0.5% slippage
            sqrtPriceLimitX96: 0
        });
        amountOut = router.exactInputSingle(params);
    }
}