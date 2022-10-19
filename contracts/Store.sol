// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./EggNFT.sol";


//Block public users to mint nfts without buying (may require owner, may require owner to set a store address to be validate)
//Verify how to bound the IDS to the owners, so we can know the token Id from the owner address

contract Store {
    address public owner;
    uint256 public price;
    EggNFT public NFT;

    event Buy(address indexed buyer, uint256 indexed tokenId);

    constructor(address _nft) {
        owner = msg.sender;
        NFT = EggNFT(_nft);
        price = 1 ether;
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == owner, "Only owner can set price");
        price = _price;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        owner = _newOwner;
    }

    function buy() public payable returns (uint256) { 
        require(msg.value >= price, "Price is not correct");
        uint256 tokenId = NFT.hatch(msg.sender);
        emit Buy(msg.sender, tokenId);
        return tokenId;
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }
}
