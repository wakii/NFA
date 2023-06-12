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

///@notice Test for Strategy Working.
///@dev    Test in fork environment(arbitrum) : `forge test --fork-url ${FORK_ARB_URL} --match-path test/Strategy.t.sol -vvvv`
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

        strategy = new Strategy(address(vault), address(weth), address(wstEth), 0xE592427A0AEce92De3Edee1F18E0157C05861564, 0x1F98431c8aD98523631AE4a59f267346ea31F984);
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

    function testSwap() public {
        testInitialDepositSet();
        strategy.swap();
        console.log(weth.balanceOf(address(strategy)));
        console.log(wstEth.balanceOf(address(strategy)));
        console.log(vault.totalAssets());
        console.log(strategy.totalAssets());
    }

    function testEstimateAmounts() public {
        console.log(strategy.estimateAmountOut(address(weth), address(wstEth), 1000));
        console.log(strategy.estimateAmountOut(address(wstEth), address(weth), 1000));
        
        console.log(strategy.estimateAmountIn(address(weth), address(wstEth), 1000));
        console.log(strategy.estimateAmountIn(address(wstEth), address(weth), 1000));
        console.log(strategy.estimateAmountIn(address(weth), address(wstEth), 9969999));
        console.log(strategy.estimateAmountOut(address(wstEth), address(weth), 8893239));
    }

    function testWithdraw() public {
        uint256 beforeWeth = weth.balanceOf(address(this));
        testInitialDepositSet();
        strategy.swap();
        uint shares = vault.balanceOf(address(this));
        // console.log(strategy.estimateAmountOut(address(wstEth), address(weth), 8893239));
        // console.log(strategy.estimateAmountIn(address(weth), address(wstEth), 10052780));
        vault.redeem(shares, address(this), address(this));
        uint afterWeth = weth.balanceOf(address(this));
        assertEq(vault.totalAssets(), 0);
        assertApproxEqAbs(beforeWeth, afterWeth, beforeWeth/ 100); // 1% loss or return allow
    }

    function testFailBadOwnership() public {
        address badUser = makeAddr('bad');
        
        vm.expectRevert("Unauthorized Caller : Vault");
        vm.prank(badUser);
        strategy.withdraw(10);
    }



}