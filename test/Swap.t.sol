import "forge-std/Test.sol";

interface IWETH {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

contract SwapTest is Test {
    IWETH public weth;

    function setUp() public {
        // arbitrum IWETH 
        weth = IWETH(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    }
    
    function testDeposit() public {
        uint beforeBal = weth.balanceOf(address(this));
        weth.deposit{value: 100}();
        uint afterBal = weth.balanceOf(address(this));
        assertEq(afterBal - beforeBal, 100);
    }
}