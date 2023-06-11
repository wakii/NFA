// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Strategy.sol";
import "../src/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function deposit() external payable;
}

contract StrategyTest is Test {
    IWETH public weth;
    IERC20 public wstEth;
    
    Vault public vault;
    Strategy public strategy;

    function setUp() public {
        // arbitrum
        weth = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        wstEth = IERC20(0x5979D7b546E38E414F7E9822514be443A4800529);

        vault = new Vault(address(weth), "TestVAULT", "TVLT");
        weth.deposit{value: 10000000}(); 

        strategy = new Strategy(address(weth), address(wstEth), 0xE592427A0AEce92De3Edee1F18E0157C05861564, 0x1F98431c8aD98523631AE4a59f267346ea31F984);
        vault.addStrategy(address(strategy));
    }

    function testDeploy() public {
        address underlying = address(strategy.asset());
        address want = address(strategy.want());
        assertEq(underlying, address(weth));
        assertEq(want, address(wstEth));
        // assert(vault.strategy() != address(0x0));
        console.log(vault.strategy());
    }

    function testInitialDepositSet() public {
        uint256 depositAmount = weth.balanceOf(address(this));
        weth.approve(address(vault), type(uint256).max);
        vault.deposit(depositAmount, address(this));
        assertEq(vault.totalAssets(), depositAmount);
        vault.rebalance();
        assertEq(vault.totalAssets(), strategy.totalAssets());
        assertEq(strategy.totalAssets(), depositAmount);
    }

    function testTotalAsset() public {
    }

    function testSwap() public {
        testInitialDepositSet();
        strategy.swap();
        console.log(weth.balanceOf(address(strategy)));
        console.log(wstEth.balanceOf(address(strategy)));
        console.log(vault.totalAssets());
        console.log(strategy.totalAssets());
    }

    function testEstimateAmountIn() public {
        console.log(strategy.estimateAmountOut(address(weth), address(wstEth), 1000));
        console.log(strategy.estimateAmountOut(address(wstEth), address(weth), 1000));
    }

    // function testWithdraw() public {
    //     uint256 beforeWeth = weth.balanceOf(address(this));
    //     // console.log(beforeWeth);
    //     testInitialDepositSet();
    //     strategy.swap();
    //     uint shares = vault.balanceOf(address(this));
    //     // console.log(shares);
    //     vault.redeem(shares, address(this), address(this));
    //     // vault.withdraw(beforeWeth, address(this), address(this));
    //     uint afterWeth = weth.balanceOf(address(this));
    //     // console.log(afterWeth);
    // }

}