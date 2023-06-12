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
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


///@notice Test for Vault in Arbitrum Fork Environment.
///@dev    Command : `forge test --fork-url ${FORK_ARB_URL} --match-path test/Strategy.t.sol -vvvv`
contract VaultWithForkTest is Test {
    IWETH public weth;
    IERC20 public wstEth;

    Vault public vault;
    Strategy public strategy;
    // ERC20Mock public want;
    IWETH public want;
    uint256 public INITIAL_WANT_BALANCE = 100 ether;

    address public userA = makeAddr('userA');
    address public userB = makeAddr('userB');

    // address testAddr = makeAddr("Test");

    function setUp() public {
        want = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        wstEth = IERC20(0x5979D7b546E38E414F7E9822514be443A4800529);
        vault = new Vault(address(want), "VAULT", "VLT");

        want.deposit{value: INITIAL_WANT_BALANCE}();
        strategy = new Strategy(address(vault), address(weth), address(wstEth), 0xE592427A0AEce92De3Edee1F18E0157C05861564, 0x1F98431c8aD98523631AE4a59f267346ea31F984);
        vault.addStrategy(address(strategy));

        userA.call{value: INITIAL_WANT_BALANCE}("");
        userB.call{value: INITIAL_WANT_BALANCE}("");


        vm.startPrank(userA);
        want.deposit{value: INITIAL_WANT_BALANCE}();
        want.approve(address(vault), type(uint256).max);
        vm.stopPrank();
        vm.startPrank(userB);
        want.deposit{value: INITIAL_WANT_BALANCE}();
        want.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        want.approve(address(vault), type(uint256).max);
    }
    
    function testGetAssetAddress() public {
        assertEq(vault.asset(), address(want));
    }

    function testInitialMint(uint256 shares) public {
        vm.assume(shares < INITIAL_WANT_BALANCE && shares > 0);
        uint256 beforeTotalShares = vault.totalSupply();
        uint256 beforeTotalAssets = vault.totalAssets();

        uint assets = vault.mint(shares, address(this));

        uint256 afterTotalShares = vault.totalSupply();
        uint256 afterTotalAssets = vault.totalAssets();

        assertEq(afterTotalShares, beforeTotalShares + shares, "Supply Should be increased after deposit");
        assertEq(afterTotalAssets, beforeTotalAssets + assets, "Managed Assets Should be increased after deposit");
    }

    function testInitialDeposit(uint256 assets) public {
        vm.assume(assets < INITIAL_WANT_BALANCE && assets > 0);
        uint256 beforeTotalShares = vault.totalSupply();
        uint256 beforeTotalAssets = vault.totalAssets();

        uint shares = vault.deposit(assets, address(this));

        uint256 afterTotalShares = vault.totalSupply();
        uint256 afterTotalAssets = vault.totalAssets();
        
        assertEq(afterTotalShares, beforeTotalShares + shares, "Supply Should be increased after deposit");
        assertEq(afterTotalAssets, beforeTotalAssets + assets, "Managed Assets Should be increased after deposit");
    }

    function testSingleDepositWithdraw(uint256 assets) public {
        vm.assume(assets < INITIAL_WANT_BALANCE && assets > 0);
        vm.prank(userA);
        want.approve(address(vault), assets);
        assertEq(want.allowance(userA, address(vault)), assets);

        // Initial Deposit
        uint256 initialBalance = want.balanceOf(userA);
        vm.prank(userA);
        uint256 userShares = vault.deposit(assets, userA);

        assertEq(assets, userShares);
        assertEq(vault.balanceOf(userA), userShares);
        assertEq(vault.totalAssets(), assets);
        assertEq(vault.totalSupply(), userShares);
        assertEq(vault.previewWithdraw(userShares), assets);
        assertEq(vault.convertToAssets(userShares), assets);

        // Withdraw
        vm.prank(userA);
        uint userAfterShares = vault.withdraw(assets, userA, userA);
        
        assertEq(vault.totalAssets(), 0);
        assertEq(vault.balanceOf(userA), 0);
        assertEq(vault.convertToAssets(vault.balanceOf(userA)), 0);
        assertEq(want.balanceOf(userA), initialBalance);
    }
    
    function testSingleMintRedeem(uint256 amount) public {
        vm.assume(amount < INITIAL_WANT_BALANCE && amount > 0);

        vm.prank(userA);
        want.approve(address(vault), amount);
        assertEq(want.allowance(userA, address(vault)), amount);

        // Initial Mint
        uint256 initialBalance = want.balanceOf(userA);
        vm.prank(userA);
        uint256 userAssets = vault.mint(amount, userA);

        assertEq(vault.balanceOf(userA), amount);
        assertEq(vault.totalAssets(), amount);
        assertEq(vault.totalSupply(), amount);
        assertEq(vault.previewWithdraw(userAssets), amount);
        assertEq(vault.convertToAssets(userAssets), amount);

        // Redeem
        vm.prank(userA);
        uint256 userAfterAssets = vault.redeem(amount, userA, userA);
        console.log(vault.totalAssets());
        assertEq(vault.totalAssets(), 0);
        assertEq(vault.balanceOf(userA), 0);
        assertEq(vault.convertToAssets(vault.balanceOf(userA)), 0);
        assertEq(want.balanceOf(userA), initialBalance);
    }

// /@notice UnComment for test. temporary being comment for compile memory issue.
    // function testMultipleDepositWithdrawMintRedeem() public {
    //     // 0. Setting

    //     vm.prank(userA);
    //     want.approve(address(vault), 10000);
    //     vm.prank(userB);
    //     want.approve(address(vault), 20000);

    //     assertEq(want.allowance(userA, address(vault)), 10000);
    //     assertEq(want.allowance(userB, address(vault)), 20000);

    //     // 1. Scenario 1 : User A deposits 2000 tokens
    //     vm.startPrank(userA);
    //     uint256 userAShares = vault.deposit(1000, userA);
    //     uint256 userAAssets = vault.previewRedeem(userAShares);
    //     assertEq(vault.balanceOf(userA), userAShares);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAAssets);
    //     assertEq(vault.convertToShares(userAAssets), vault.balanceOf(userA));

    //     assertEq(vault.totalSupply(), userAShares);
    //     assertEq(vault.totalAssets(), userAAssets);

    //     // 2. Scenario 2 : User B mints 2000 shares
    //     changePrank(userB);
    //     uint256 userBAssets = vault.mint(2000, userB);
    //     uint256 userBShares = vault.previewWithdraw(userBAssets);
    //     assertEq(vault.balanceOf(userB), userBShares);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userB)), userBAssets);
    //     assertEq(vault.convertToShares(userBAssets), vault.balanceOf(userB));

    //     uint256 afterShares = userAShares + userBShares;
    //     uint256 afterAssets = userAAssets + userBAssets;
    //     assertEq(vault.totalSupply(), userAShares + userBShares);
    //     assertEq(vault.totalAssets(), userAAssets + userBAssets);
    //     vm.stopPrank();

    //     // 3. Scenario 3 : Vault Harvested 
    //     uint256 harvestedAssets = 3000;
        
    //     want.transfer(address(vault), harvestedAssets);
    //     assertEq(vault.totalSupply(), afterShares); // Shares not changed;
    //     assertEq(vault.totalAssets(), afterAssets + harvestedAssets);
    //     assertEq(vault.balanceOf(userA), userAShares);
    //     assertEq(vault.balanceOf(userB), userBShares);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAAssets + harvestedAssets * (userAShares) / (afterShares));
    //     assertEq(vault.convertToAssets(vault.balanceOf(userB)), userBAssets + harvestedAssets * (userBShares) / (afterShares));

    //     // 4. Scenario 4 : UserA withdraw
    //     uint256 userABeforeWithdraw = want.balanceOf(userA);
    //     uint256 userAWithdrawAssets = 1000;
        
    //     uint256 beforeTotalSupply = vault.totalSupply();
    //     uint256 beforeTotalAssets = vault.totalAssets();
    //     uint256 userAEstimatedAssets = beforeTotalAssets * (userAShares) / beforeTotalSupply;
    //     uint256 userAEstimatedShares = beforeTotalSupply * userAWithdrawAssets / beforeTotalAssets;
    //     vm.startPrank(userA);
    //     uint256 userAReceivedShares = vault.withdraw(userAWithdrawAssets, userA, userA);
    //     assertEq(userAReceivedShares, userAEstimatedShares);
    //     assertEq(want.balanceOf(userA), userABeforeWithdraw + userAWithdrawAssets);
    //     assertEq(vault.totalSupply(), beforeTotalSupply - userAEstimatedShares);
    //     assertEq(vault.totalAssets(), beforeTotalAssets - userAWithdrawAssets);
    //     assertEq(vault.balanceOf(userA), userAShares - userAEstimatedShares);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAEstimatedAssets - userAWithdrawAssets);

    //     // 5. Scenario 5 : UserB Redeem
    //     uint256 userBBeforeWithdraw = want.balanceOf(userB);
    //     beforeTotalSupply = vault.totalSupply();
    //     beforeTotalAssets = vault.totalAssets();
        
    //     uint256 userBEstimatedAssets = beforeTotalAssets * (userBShares) / beforeTotalSupply;

    //     changePrank(userB);
    //     uint256 userBReceivedAssets = vault.redeem(userBShares, userB, userB);
    //     assertEq(userBReceivedAssets, userBEstimatedAssets);
    //     assertEq(want.balanceOf(userB), userBBeforeWithdraw + userBEstimatedAssets);
    //     assertEq(vault.totalSupply(), beforeTotalSupply - userBShares);
    //     assertEq(vault.totalAssets(), beforeTotalAssets - userBEstimatedAssets);
    //     assertEq(vault.balanceOf(userB), 0);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userB)), 0);

    //     // // 6. Scenario 6. : UserA Withdraw All
    //     userABeforeWithdraw = want.balanceOf(userA);
    //     beforeTotalSupply = vault.totalSupply();
    //     beforeTotalAssets = vault.totalAssets();
    //     userAEstimatedAssets = beforeTotalAssets * vault.balanceOf(userA) / beforeTotalSupply;
    //     userAEstimatedShares = beforeTotalSupply * userAEstimatedAssets / beforeTotalAssets;
    //     // console.log(address(userA), address(userB));
    //     changePrank(userA);
    //     userAReceivedShares = vault.withdraw(vault.convertToAssets(vault.balanceOf(userA)), userA, userA);
    //     assertEq(userAReceivedShares, userAEstimatedShares);
    //     assertEq(want.balanceOf(userA), userABeforeWithdraw + userAEstimatedAssets);
    //     assertEq(vault.totalSupply(), 0);
    //     assertEq(vault.totalAssets(), 0);
    //     assertEq(vault.balanceOf(userA), 0);
    //     assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAEstimatedAssets - userAWithdrawAssets);              
    // }

    function testOwnshipCheck() public {
        
    }

}
