// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IStrategy {
    function asset() external view returns(address);
    function totalAssets() external view returns(uint256 totalManagedAssets);
    function deposit() external;
    function withdraw(uint256 amountDebt) external;

}