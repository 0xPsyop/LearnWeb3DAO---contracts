//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
   
address public cryptoDevTokenAddress;

 constructor(address _cryptoDevToken) ERC20("CryptoDev LP Token" ,"CDLP") {
      require(_cryptoDevToken != address(0), "Token address passed is a null address");
      cryptoDevTokenAddress = _cryptoDevToken;
 }

function getReserve() public view returns(uint) {
   return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
}

function addLiquidity(uint _amount) public payable returns(uint) {
   uint liquidity;
   uint ethBalance = address(this).balance;
   uint cryptoDevTokenReserve = getReserve();
   ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

   if(cryptoDevTokenReserve == 0) {

      cryptoDevToken.transferFrom(msg.sender, address(this), _amount);

      liquidity = ethBalance;
      _mint(msg.sender, liquidity);
   } else {
     
    uint ethReserve = ethBalance- msg.value;
   
    uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve)/(ethReserve);
    
    require(_amount >= cryptoDevTokenAmount , "Amount of tokens sent is less than the minimum tokens required");

     liquidity = (totalSupply() * msg.value)/ ethReserve;

    _mint(msg.sender, liquidity );

   }

 return liquidity;

}

function removeLiquidity(uint amount) public returns(uint, uint){


  require(amount > 0, "The value ahould be greater than zero");
  uint ethReserve = address(this).balance;
  uint _totalSupply = totalSupply();

  uint ethAmount  = ( ethReserve * amount)/ _totalSupply;
  uint cryptoDevTokenAmount = (getReserve() * amount) /_totalSupply;
  
  _burn(msg.sender, amount);
 payable(msg.sender).transfer(ethAmount);
 ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
 
 return(ethAmount, cryptoDevTokenAmount);
}

function getAmountOfTokens (
    uint256 inputAmount,
    uint256 inputReserve,
    uint256 outputReserve 
) public pure returns(uint256){
   require(inputReserve > 0 && outputReserve > 0, "Invalid amounts");

   uint inputAmountWithFees  = inputAmount * 99/100;
   // So the final formula is Δy = (y * Δx) / (x + Δx)
   uint numerator = outputReserve * inputAmountWithFees;
   uint denominator = inputReserve  + inputAmountWithFees;

   return numerator/ denominator;
}

function ethToDevToken(uint _minTokens) public payable {
   uint tokenReserve = getReserve();

   uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenReserve);
   
   require(tokensBought > _minTokens, "insuffiecient output amount");
   ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
}

function devTokenToEth(uint _tokensSold, uint _minEth) public {
    uint tokenReserve = getReserve();

    uint ethBought = getAmountOfTokens(_tokensSold, tokenReserve, address(this).balance);

    require(_minEth > ethBought , "insuffiecient output amount");
    ERC20(cryptoDevTokenAddress).transferFrom(msg.sender, address(this), _tokensSold);
    payable(msg.sender).transfer(ethBought);
}
}

