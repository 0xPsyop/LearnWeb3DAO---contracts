//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{

    string _baseTokenURI;

    IWhitelist whitelist;

    bool public presaleStarted;
    bool public _paused;
    uint256 public presaleEnded;
    uint256 public tokenId;
    uint256 public maxTokenSupply = 20;
    uint256 public _price = 0.069 ether;

   
   constructor(string memory baseURI, address whitelistContract) ERC721 ("Crypto Devs", "CD"){
          
          _baseTokenURI = baseURI;
           whitelist = IWhitelist(whitelistContract);
   }

   modifier whenNotPaused {
       require(!_paused, "The contract is paused");
       _ ;
   }

   function startPresale() public onlyOwner {
          presaleStarted = true;
          presaleEnded = block.timestamp + 5 minutes;
   }

   function presaleMint() public payable whenNotPaused{
       require(presaleStarted && block.timestamp < presaleEnded, "presale ended");
       require(whitelist.whitelistAddresses(msg.sender), "You are not whitelisted");
       require(maxTokenSupply >= tokenId, "The supply is exceeded");
       require(msg.value >= _price, "Not enough ether to mint");
        
        tokenId++ ;
       _safeMint(msg.sender, tokenId);

   }

   function mint () public payable whenNotPaused{
       require(presaleStarted && block.timestamp >= presaleEnded);
       require(maxTokenSupply >= tokenId, "The supply is exceeded");
       require(msg.value >= _price, "Not enough ether to mint"); 

        tokenId ++ ;
       _safeMint(msg.sender, tokenId);

   }

   function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

   function withdraw() public onlyOwner {
       address _owner = owner();
       uint256 balance  = address(this).balance;
       (bool sent, ) = _owner.call{value: balance}("");
       require(sent, "Failed to withdrwa Ether");
   } 

   function setPaused(bool val) public onlyOwner {
        _paused = val;
   }
   
   receive() external payable {} 
   fallback()  external payable {} 
  
}
