//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface ICryptoDevs {
  
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
  function balanceOf(address owner) external view returns (uint256);
}