pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import "../src/SwapModule.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IWETH {
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function deposit() external payable;
}

contract SwapTest is Test {
    IWETH public weth;
    IERC20 public wstETH;

    function setUp() public {
        // arbitrum IWETH 
        weth = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        wstETH = IERC20(0x5979D7b546E38E414F7E9822514be443A4800529);
    }

    function testNetwork() public {
        console.log("WETH total supply : ", weth.totalSupply());
        console.log("wstETH total supply : ", wstETH.totalSupply());
    }
    
    function testDeposit() public {
        uint beforeBal = weth.balanceOf(address(this));
        weth.deposit{value: 100}();
        uint afterBal = weth.balanceOf(address(this));
        assertEq(afterBal - beforeBal, 100);
    }
}