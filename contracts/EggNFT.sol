// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "hardhat/console.sol";

//4398
//c402a3d72332c3ebcd359f3f6fd8af49472ebd3dc92272a0e6355fa1379758d1

contract EggNFT is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    address public owner;
    address public store;
    uint256 MAX_SUPPLY = 10_000;

    enum Pokemon {
        first,
        second,
        third,
        rare
    }

    struct NftData {
        Pokemon pokemon;
        string CID;
    }

    mapping (uint256 => NftData) public pokemons;
    mapping (uint256 => address) public requestIdToSender;

    uint256 public randomness = 0;

    //declare baseURI
    string public baseURI = "https://ipfs.io/ipfs/";

    /*
    VRFCoordinatorV2Interface private immutable iVRFCoordinator;
    bytes32 private immutable s_keyHash;
    uint64 private immutable s_subscriptionId;
    uint32 private constant CALLBACK_GAS_LIMIT = 100000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    */

    constructor() ERC721("EggNFT", "EGG") {
        owner = msg.sender;

        NftData memory pokemonFirst;
        pokemonFirst.pokemon = Pokemon.first;
        pokemonFirst.CID = "QmdMbe2Sb8NwSWStnXAoCUPfEHfZhPEEEDeRSM6vimYg1M";

        NftData memory pokemonSecond;
        pokemonSecond.pokemon = Pokemon.second;
        pokemonSecond.CID = "QmX2LWtS8vMvA7ntgKqCxcNqMnzBSMQEx37rkFtAfMjmWy";

        NftData memory pokemonThird;
        pokemonThird.pokemon = Pokemon.third;
        pokemonThird.CID = "QmdtihBnL7EY49PMwqUcrRdYEKQxdeGDshgH66VNeqvMQ9";

        NftData memory pokemonRare;
        pokemonRare.pokemon = Pokemon.rare;
        pokemonRare.CID = "QmcDVLSismCdnXiaBVViou7oUm1uQ6B6S6Z56AQnVYWgph";

        pokemons[1] = pokemonFirst;
        pokemons[2] = pokemonSecond;
        pokemons[3] = pokemonThird;
        pokemons[4] = pokemonRare;

    }

    function _baseURI() internal override view virtual returns (string memory) {
        return baseURI;
    }

    function setStoreAddress(address _store) public {
        require(msg.sender == owner);
        store = _store;
    }

    function requestRandomWords(uint256 number) public  {
        fulfillRandomWords(1, number);
    }
    
    function fulfillRandomWords(uint256 requestId, uint256 randomNumber) public {
        console.log("Randomness: %s", randomNumber);
        //select from pokemons mapping based on pokemonSelected

        uint256 pokemonSelected = randomNumber % 4 + 1;

        NftData memory pokemon = pokemons[pokemonSelected];
        safeMint(requestIdToSender[_tokenIdCounter.current()], pokemon.CID);
    }

    function hatch(address happyOwner) public returns (uint256 tokenId) {
        require(happyOwner != address(0), "Owner cannot be 0 address");
        require(store != address(0), "Store address not set");
        require(msg.sender == store);
        require(_tokenIdCounter.current() < MAX_SUPPLY, "All tokens have been minted");
        _tokenIdCounter.increment();
        requestIdToSender[_tokenIdCounter.current()] = happyOwner;

        //fake randomness
        requestRandomWords(1);
        
        return _tokenIdCounter.current();
    }

    //implement safeMint function
    function safeMint(address to, string memory uri) internal returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        console.log("Minted token with ID: %s", tokenId);
        return tokenId;
    }

    //function to list all nfts from address
    function listNFTs(address owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //function fulfillRandomWords

    
}
