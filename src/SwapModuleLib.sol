// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import {IERC20} from "forge-std/interfaces/IERC20.sol";


///@notice Library for swaping with Uniswap-V3 functions. 
///@dev    Refs : https://blog.uniswap.org/uniswap-v3-math-primer
library SwapModuleLib {
    function estimateAmountOut(address factory, address tokenIn, address tokenOut, uint256 amountIn) internal view returns(uint256 amountOut) {
        if(amountIn == 0) return 0;
        IUniswapV3Pool pool = IUniswapV3Pool(IUniswapV3Factory(factory).getPool(tokenIn, tokenOut, 3000));
        require(address(pool) != address(0), "POOL NOT EXISTS");

        (uint160 sqrtPriceX96,,,,,,)  = pool.slot0();
        uint256 price = 
            (uint256(sqrtPriceX96)**2 * 10**(18-(IERC20(pool.token0()).decimals() - IERC20(pool.token1()).decimals()))) >> (96 * 2);
        return amountOut = 
            tokenOut == pool.token0() ? 
            amountIn * 1e18 / price :
            amountIn * price / 1e18;
    }

    function estimateAmountIn(address factory, address tokenIn, address tokenOut, uint256 amountOut) internal view returns(uint256 amountIn) {
        if(amountOut == 0) return 0;
        IUniswapV3Pool pool = IUniswapV3Pool(IUniswapV3Factory(factory).getPool(tokenIn, tokenOut, 3000));
        require(address(pool) != address(0), "POOL NOT EXISTS");

        (uint160 sqrtPriceX96,,,,,,)  = pool.slot0();
        uint256 price = 
            (uint256(sqrtPriceX96)**2 * 10**(18-(IERC20(pool.token0()).decimals() - IERC20(pool.token1()).decimals()))) >> (96 * 2);
        return amountIn = 
            tokenIn == pool.token1() ? 
            amountOut * 1e18 / price :
            amountOut * price / 1e18;
    }


    ///@dev Deprecated. Version of using UniswapOracleLibrary. Use Pool Math Calculation instead for gas efficiency.
    // function estimateAmountOut(address factory, address tokenIn, address tokenOut, uint256 amountIn) internal view returns(uint256 amountOut) {
    //     if(amountIn == 0) return 0;

    //     address pool = IUniswapV3Factory(factory).getPool(tokenIn, tokenOut, 3000);
    //     require(pool != address(0), "POOL NOT EXISTS");

    //     (int24 tick, ) = OracleLibrary.consult(pool, 10); // 10 seconds ago
    //     amountOut = OracleLibrary.getQuoteAtTick(
    //         tick,
    //         uint128(amountIn), // casting 
    //         tokenIn,
    //         tokenOut
    //         );
    // }   


    function swapExactInput(address router, address tokenIn_, address tokenOut_, uint256 amountIn_) internal returns (uint256 amountOut) {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn_,
            tokenOut: tokenOut_,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn_,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        amountOut = ISwapRouter(router).exactInputSingle(params);
    }

    function swapExactOutput(address router, address tokenIn_, address tokenOut_, uint256 amountOut_) internal returns (uint256 amountIn) {
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: tokenIn_,
            tokenOut: tokenOut_,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: amountOut_,
            amountInMaximum: type(uint256).max,
            sqrtPriceLimitX96: 0
        });
        amountIn = ISwapRouter(router).exactOutputSingle(params);
    }
}