// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;

    function setUp() public {
    }
    
    function testGetAssetAddress(address assetAddress_, string memory name_, string memory symbol_) public {
        vault = new Vault(assetAddress_, name_, symbol_);
        assertEq(vault.asset(), assetAddress_);
    }
}
