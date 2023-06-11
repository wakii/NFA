pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import "../src/SwapModule.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function deposit() external payable;
}

contract SwapTest is Test {
    IWETH public weth;
    IERC20 public wstETH;
    SwapModule public swapModule;

    function setUp() public {
        // arbitrum
        weth = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        wstETH = IERC20(0x5979D7b546E38E414F7E9822514be443A4800529);
        swapModule = new SwapModule(0x1F98431c8aD98523631AE4a59f267346ea31F984, 0xE592427A0AEce92De3Edee1F18E0157C05861564);
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

    function testEstimateAmountOut() public {
        uint256 amountOut = swapModule.estimateAmountOut(address(weth), address(wstETH), 100);
        console.log("Estimate : ", amountOut);
    }

    function testSwapExactInput() public {
        // address mockUser = makeAddr('userA');
        // vm.startPrank(mockUser);
        // console.log(mockUser.balance);
        

        weth.deposit{value: 10000000}();
        weth.approve(address(swapModule), type(uint256).max);
        uint amountIn = 100;
        uint256 amountOut = swapModule.swapExactInput(address(weth), address(wstETH), amountIn, address(this));
        console.log(amountOut);
    }
}