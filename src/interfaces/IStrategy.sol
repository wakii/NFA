// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface IStrategy {
    function totalAssets() external view returns(uint256 totalManagedAssets);
    // function deposit() external;
    function updateRouter() external;
    function mint() external;
    function redeem() external;
}