//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//The interfaces
interface IFakeNFTMarketplace{
    function purchase(uint256 _tokenID) external payable;

    function getPrice() external view returns(uint256);

    function available(uint256 _tokenID) external view returns(bool);
}

interface ICryptoDevsNFT {
 function balanceOf(address owner) external view returns(uint256);

 function tokenOfOwnerByIndex(address owner, uint index) external view returns(uint256);
}


contract CryptoDevsDAO is Ownable{

    struct Proposal{

        uint256 nftTokenId;
        uint256 yayVotes;
        uint256 nahVotes;
        uint256 deadline;
        bool executed;
        mapping (uint256 => bool) voters;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256 numProposals;
   
    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;

    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable{
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }


    //create a proposal

     modifier nftHolderOnly(){
        require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "You don't own any NFTs GTFO");
        _ ;
    }

    function createProposal( uint256 _nftTokenId) external nftHolderOnly returns(uint256){
        require(nftMarketplace.available(_nftTokenId));

        Proposal storage proposal  = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline  = block.timestamp + 5 minutes;
        
        numProposals++;

        return numProposals -1;

    }
    
    //vote on a proposal

     modifier activeOnly(uint256 _proposalIndex){
        require(block.timestamp < proposals[_proposalIndex].deadline, "The proposal is expired");
        _;
    }

    enum Vote {
        YAY,
        NAH
    }

    function voteOnProposal(uint256 _proposalIndex, Vote vote ) external nftHolderOnly activeOnly(_proposalIndex) {
          Proposal storage proposal = proposals[_proposalIndex];

          uint256 voterNftBalance = cryptoDevsNFT.balanceOf(msg.sender);
           uint256 numVotes = 0;

           for(uint i=0; i < voterNftBalance; i++){
              uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
               if (proposal.voters[tokenId] == false) {
                     numVotes++;
                     proposal.voters[tokenId] = true;
                    }
           }
         require(numVotes > 0, "Already Voted");
         
         if(vote == Vote.YAY)  {
             proposal.yayVotes += numVotes;
         } else {
             proposal.nahVotes += numVotes;
         }

    }
    //execute the proposal

    modifier inactiveProposalOnly(uint256 _proposalIndex){
        require(block.timestamp >= proposals[_proposalIndex].deadline , "The voting hasn't ended yet");
        require(proposals[_proposalIndex].executed == false, "the proposal is already executed");
        _;
    }
    
    function executeProposal(uint256 _proposalIndex) external nftHolderOnly inactiveProposalOnly(_proposalIndex) {
          Proposal storage proposal = proposals[_proposalIndex];
          
          if(proposal.yayVotes > proposal.nahVotes){

              uint256 price = nftMarketplace.getPrice();
              require(address(this).balance >= price, "Just too poor lol");

              nftMarketplace.purchase{value: price}(proposal.nftTokenId);
              
          } 

          proposal.executed = true;
    }
    
    // additional features to withdraw ethreum

    function withdrawEther() external onlyOwner {
         payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {} 

} 