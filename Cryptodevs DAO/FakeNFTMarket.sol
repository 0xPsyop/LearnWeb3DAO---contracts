//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract FakeNFTMarketplace {
  
  mapping (uint256 => address) public tokens;
  uint256 nftPrice = 0.69 ether;

  function purchase(uint256 _tokenID) external payable {
   require(msg.value == nftPrice, "This NFT is 0.69 ethers lol");
   tokens[_tokenID] = msg.sender;

  }

  function getPrice() external view returns(uint256) {
     return nftPrice;
  }

  function available(uint256 _tokenID) external view returns(bool) {
   if(tokens[_tokenID] == address(0)){
       return true;
   }
   return false;
  }
}
