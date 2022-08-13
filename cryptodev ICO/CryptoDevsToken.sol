//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {

    ICryptoDevs CryptoDevsNFT;

    uint256 public constant maxTotalSupply = 10000 * 10**18;

    uint256 public constant _price  = 0.001 ether;

    uint256 public constant tokensPerNFT = 10 *10 **18;

    mapping( uint256 => bool) public claimedTokenIds;
   
   constructor(address _CryptoDevsContract) ERC20 ("Crypto Dev Token","CDT") {
      CryptoDevsNFT = ICryptoDevs(_CryptoDevsContract);
   }
   
   function claim () public {
      uint256 amount  = 0;
      uint256 balance = CryptoDevsNFT.balanceOf(msg.sender);  
      require ( balance > 0, "You don't own any crypto dev NFTs");
      
      for( uint256 i= 0; i < balance; i++ ){
         uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);

         if(!claimedTokenIds[tokenId]){
            amount +=1;
           claimedTokenIds[tokenId] = true;
         }
        
      }
      require(amount > 0 , "You have claimed all your free tokens, bitch!!");

      _mint(msg.sender, amount* tokensPerNFT);
   }

   function mint (uint256 amount) public payable {
      uint256 amountInDecimals = amount * 10**18;
      uint256 _requiredValue  = amount * _price;

      require(msg.value >= _requiredValue, "The Ether isn't enough");
         
      require( maxTotalSupply >= (totalSupply() + amountInDecimals) , " The total supply is gone bitch!! ");

      _mint( msg.sender , amountInDecimals);

   }

   receive() external payable {}
   fallback() external payable {}
}
