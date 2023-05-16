// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address testAddr = makeAddr("Test");

    function setUp() public {
        vault = new Vault(testAddr, "VAULT", "VLT");
    }
    
    function testGetAssetAddress() public {
        assertEq(vault.asset(), testAddr);
    }

    function testMint(uint256 shares) public {
        uint256 beforeTotalShares = vault.totalSupply();
        uint256 beforeTotalAssets = vault.totalAssets();
        uint assets = vault.mint(shares, address(this));

        uint256 afterTotalShares = vault.totalSupply();
        uint256 afterTotalAssets = vault.totalAssets();
        assertEq(afterTotalShares, beforeTotalShares + shares, "Supply Should be increased after deposit");
        assertEq(afterTotalAssets, beforeTotalAssets + assets, "Managed Assets Should be increased after deposit");
    }

    function testDeposit(uint256 assets) public {
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
