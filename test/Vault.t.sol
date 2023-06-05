// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../src/Vault.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract VaultTest is Test {
//     Vault public vault;
//     ERC20Mock public want;
//     uint256 public INITIAL_WANT_BALANCE = 100 ether;

//     // address testAddr = makeAddr("Test");

//     function setUp() public {
//         want = new ERC20Mock("MOCKTOKEN","MTK", address(this), INITIAL_WANT_BALANCE);
//         vault = new Vault(address(want), "VAULT", "VLT");
//         want.approve(address(vault), type(uint256).max);
//     }
    
//     function testGetAssetAddress() public {
//         assertEq(vault.asset(), address(want));
//     }

//     function testInitialMint(uint256 shares) public {
//         vm.assume(shares < INITIAL_WANT_BALANCE && shares > 0);
//         uint256 beforeTotalShares = vault.totalSupply();
//         uint256 beforeTotalAssets = vault.totalAssets();

//         uint assets = vault.mint(shares, address(this));

//         uint256 afterTotalShares = vault.totalSupply();
//         uint256 afterTotalAssets = vault.totalAssets();

//         assertEq(afterTotalShares, beforeTotalShares + shares, "Supply Should be increased after deposit");
//         assertEq(afterTotalAssets, beforeTotalAssets + assets, "Managed Assets Should be increased after deposit");
//     }

//     function testInitialDeposit(uint256 assets) public {
//         vm.assume(assets < INITIAL_WANT_BALANCE && assets > 0);
//         uint256 beforeTotalShares = vault.totalSupply();
//         uint256 beforeTotalAssets = vault.totalAssets();

//         uint shares = vault.deposit(assets, address(this));

//         uint256 afterTotalShares = vault.totalSupply();
//         uint256 afterTotalAssets = vault.totalAssets();
        
//         assertEq(afterTotalShares, beforeTotalShares + shares, "Supply Should be increased after deposit");
//         assertEq(afterTotalAssets, beforeTotalAssets + assets, "Managed Assets Should be increased after deposit");
//     }

//     function testSingleDepositWithdraw(uint256 assets) public {
//         vm.assume(assets < INITIAL_WANT_BALANCE && assets > 0);

//         address mockUser = makeAddr('userA');

//         want.mint(mockUser, assets);
//         vm.prank(mockUser);
//         want.approve(address(vault), assets);
//         assertEq(want.allowance(mockUser, address(vault)), assets);

//         // Initial Deposit
//         vm.prank(mockUser);
//         uint256 userShares = vault.deposit(assets, mockUser);

//         assertEq(assets, userShares);
//         assertEq(vault.balanceOf(mockUser), userShares);
//         assertEq(vault.totalAssets(), assets);
//         assertEq(vault.totalSupply(), userShares);
//         assertEq(vault.previewWithdraw(userShares), assets);
//         assertEq(vault.convertToAssets(userShares), assets);


//         // Withdraw
//         vm.prank(mockUser);
//         uint userAfterShares = vault.withdraw(assets, mockUser, mockUser);
        
//         assertEq(vault.totalAssets(), 0);
//         assertEq(vault.balanceOf(mockUser), 0);
//         assertEq(vault.convertToAssets(vault.balanceOf(mockUser)), 0);
//         assertEq(want.balanceOf(mockUser), assets);
//     }
    
//     function testSingleMintRedeem(uint256 amount) public {
//         vm.assume(amount < INITIAL_WANT_BALANCE && amount > 0);

//         address mockUser = makeAddr('alice');

//         want.mint(mockUser, amount);
//         vm.prank(mockUser);
//         want.approve(address(vault), amount);
//         assertEq(want.allowance(mockUser, address(vault)), amount);

//         // Initial Mint
//         vm.prank(mockUser);
//         uint256 userAssets = vault.mint(amount, mockUser);

//         assertEq(vault.balanceOf(mockUser), amount);
//         assertEq(vault.totalAssets(), amount);
//         assertEq(vault.totalSupply(), amount);
//         assertEq(vault.previewWithdraw(userAssets), amount);
//         assertEq(vault.convertToAssets(userAssets), amount);

//         // Redeem
//         vm.prank(mockUser);
//         uint256 userAfterAssets = vault.redeem(amount, mockUser, mockUser);
        
//         assertEq(vault.totalAssets(), 0);
//         assertEq(vault.balanceOf(mockUser), 0);
//         assertEq(vault.convertToAssets(vault.balanceOf(mockUser)), 0);
//         assertEq(want.balanceOf(mockUser), amount);
//     }

//     function testMultipleDepositWithdrawMintRedeem() public {
//         address userA = makeAddr('A');
//         address userB = makeAddr('B');

//         // 0. Setting
//         want.mint(userA, 10000);
//         want.mint(userB, 20000);

//         vm.prank(userA);
//         want.approve(address(vault), 10000);
//         vm.prank(userB);
//         want.approve(address(vault), 20000);

//         assertEq(want.allowance(userA, address(vault)), 10000);
//         assertEq(want.allowance(userB, address(vault)), 20000);

//         // 1. Scenario 1 : User A deposits 2000 tokens
//         vm.startPrank(userA);
//         uint256 userAShares = vault.deposit(1000, userA);
//         uint256 userAAssets = vault.previewRedeem(userAShares);
//         assertEq(vault.balanceOf(userA), userAShares);
//         assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAAssets);
//         assertEq(vault.convertToShares(userAAssets), vault.balanceOf(userA));

//         assertEq(vault.totalSupply(), userAShares);
//         assertEq(vault.totalAssets(), userAAssets);

//         // 2. Scenario 2 : User B mints 2000 shares
//         changePrank(userB);
//         uint256 userBAssets = vault.mint(2000, userB);
//         uint256 userBShares = vault.previewWithdraw(userBAssets);
//         assertEq(vault.balanceOf(userB), userBShares);
//         assertEq(vault.convertToAssets(vault.balanceOf(userB)), userBAssets);
//         assertEq(vault.convertToShares(userBAssets), vault.balanceOf(userB));

//         uint256 afterShares = userAShares + userBShares;
//         uint256 afterAssets = userAAssets + userBAssets;
//         assertEq(vault.totalSupply(), userAShares + userBShares);
//         assertEq(vault.totalAssets(), userAAssets + userBAssets);
//         vm.stopPrank();

//         // 3. Scenario 3 : Vault Harvested 
//         // TODO update Strategy Logics    
//         uint256 harvestedAssets = 3000;
//         want.mint(address(vault), harvestedAssets);
//         assertEq(vault.totalSupply(), afterShares); // Shares not changed;
//         assertEq(vault.totalAssets(), afterAssets + harvestedAssets);
//         assertEq(vault.balanceOf(userA), userAShares);
//         assertEq(vault.balanceOf(userB), userBShares);
//         assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAAssets + harvestedAssets * (userAShares) / (afterShares));
//         assertEq(vault.convertToAssets(vault.balanceOf(userB)), userBAssets + harvestedAssets * (userBShares) / (afterShares));

//         // 4. Scenario 4 : UserA withdraw
//         uint256 userABeforeWithdraw = want.balanceOf(userA);
//         uint256 userAWithdrawAssets = 1000;
        
//         uint256 beforeTotalSupply = vault.totalSupply();
//         uint256 beforeTotalAssets = vault.totalAssets();
//         uint256 userAEstimatedAssets = beforeTotalAssets * (userAShares) / beforeTotalSupply;
//         uint256 userAEstimatedShares = beforeTotalSupply * userAWithdrawAssets / beforeTotalAssets;
//         vm.startPrank(userA);
//         uint256 userAReceivedShares = vault.withdraw(userAWithdrawAssets, userA, userA);
//         assertEq(userAReceivedShares, userAEstimatedShares);
//         assertEq(want.balanceOf(userA), userABeforeWithdraw + userAWithdrawAssets);
//         assertEq(vault.totalSupply(), beforeTotalSupply - userAEstimatedShares);
//         assertEq(vault.totalAssets(), beforeTotalAssets - userAWithdrawAssets);
//         assertEq(vault.balanceOf(userA), userAShares - userAEstimatedShares);
//         assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAEstimatedAssets - userAWithdrawAssets);

//         // 5. Scenario 5 : UserB Redeem
//         uint256 userBBeforeWithdraw = want.balanceOf(userB);
//         beforeTotalSupply = vault.totalSupply();
//         beforeTotalAssets = vault.totalAssets();
        
//         uint256 userBEstimatedAssets = beforeTotalAssets * (userBShares) / beforeTotalSupply;

//         changePrank(userB);
//         uint256 userBReceivedAssets = vault.redeem(userBShares, userB, userB);
//         assertEq(userBReceivedAssets, userBEstimatedAssets);
//         assertEq(want.balanceOf(userB), userBBeforeWithdraw + userBEstimatedAssets);
//         assertEq(vault.totalSupply(), beforeTotalSupply - userBShares);
//         assertEq(vault.totalAssets(), beforeTotalAssets - userBEstimatedAssets);
//         assertEq(vault.balanceOf(userB), 0);
//         assertEq(vault.convertToAssets(vault.balanceOf(userB)), 0);

//         // 6. Scenario 6. : UserA Withdraw All
//         userABeforeWithdraw = want.balanceOf(userA);
//         beforeTotalSupply = vault.totalSupply();
//         beforeTotalAssets = vault.totalAssets();
//         userAEstimatedAssets = beforeTotalAssets * vault.balanceOf(userA) / beforeTotalSupply;
//         userAEstimatedShares = beforeTotalSupply * userAEstimatedAssets / beforeTotalAssets;
//         // console.log(address(userA), address(userB));
//         changePrank(userA);
//         userAReceivedShares = vault.withdraw(vault.convertToAssets(vault.balanceOf(userA)), userA, userA);
//         assertEq(userAReceivedShares, userAEstimatedShares);
//         assertEq(want.balanceOf(userA), userABeforeWithdraw + userAEstimatedAssets);
//         assertEq(vault.totalSupply(), 0);
//         assertEq(vault.totalAssets(), 0);
//         assertEq(vault.balanceOf(userA), 0);
//         assertEq(vault.convertToAssets(vault.balanceOf(userA)), userAEstimatedAssets - userAWithdrawAssets);              
//     }

// }
