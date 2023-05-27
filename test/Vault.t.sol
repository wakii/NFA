// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import {MockERC20} from "./utils/MockERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultTest is Test {
    Vault public vault;
    IERC20 public want;
    uint256 public INITIAL_WANT_BALANCE = 100 ether;

    // address testAddr = makeAddr("Test");

    function setUp() public {
        want = new MockERC20(INITIAL_WANT_BALANCE, "MOCKTOKEN","MTK");
        vault = new Vault(address(want), "VAULT", "VLT");
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

    function testWithdraw(uint256 assets) public {
        uint256 beforeTotalShares = vault.totalSupply();
        uint256 beforeTotalAssets = vault.totalAssets();

        uint256 shares = vault.withdraw(assets, address(this), address(this));
        
        uint256 afterTotalShares = vault.totalSupply();
        uint256 afterTotalAssets = vault.totalAssets();
        assertEq(beforeTotalShares - shares, afterTotalShares, "Supply Should be decreased after withdraw");
        assertEq(beforeTotalAssets - assets, afterTotalAssets, "Managed Assets Should be decreased after withdraw");
    }
}
