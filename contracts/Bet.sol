pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Bet {
    using Counters for Counters.Counter;
    Counters.Counter public tokenIdCounter;

    struct MatchNfts {
        address playerOneNfts;
        uint256 playerOneNftId;
        address playerTwoNfts;
        uint256 playerTwoNftId;
    }

    enum MatchStatus {Open, Closed}

    event MatchOpen(address indexed playerOne, address indexed nftAddress, uint256 indexed timeStamp);
    event MatchClosed(address indexed winner, address indexed loser, uint256 timestamp);
    event JoinedMatch(address indexed playerOne, address indexed playerTwo);

    struct Match {
        uint256 id;
        address playerOne;
        address playerTwo;
        uint256 timestamp;
        MatchNfts nfts;
        MatchStatus status;
    }

    mapping(uint256 => Match) public openedMatches;
    mapping(uint256 => Match) public closedMatches;

    /*
    function approveMatch(address _nftAddress, uint256 _nftId) internal {
        ERC721 nft = ERC721(_nftAddress);
        nft.approve(address(this), _nftId);
    }*/

    function createMatch(address nftAddress, uint256 nftId) external {
        require(msg.sender != address(0), "Invalid addresss");
    
        //approveMatch(nftAddress, nftId);

        tokenIdCounter.increment();

        Match memory playerMatch = Match({
            id: tokenIdCounter.current(),
            playerOne: msg.sender,
            playerTwo: address(0),
            timestamp: block.timestamp,
            nfts: MatchNfts({
                playerOneNfts: nftAddress,
                playerOneNftId: nftId,
                playerTwoNfts: address(0),
                playerTwoNftId: 0
            }),
            status: MatchStatus.Open
        });

        ERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);

        openedMatches[tokenIdCounter.current()] = playerMatch;

        emit MatchOpen(msg.sender, nftAddress, block.timestamp);
    }


    function join(uint256 matchId, address nftAddress, uint256 nftId) external {
        require(msg.sender != address(0), "Invalid addresss");
        require(openedMatches[matchId].playerOne != address(0), "Match does not exist");
        require(openedMatches[matchId].playerOne != msg.sender, "You cannot join your own match");
        require(openedMatches[matchId].playerTwo == address(0), "Match is already full");
        //require(openedMatches[matchId].nfts.playerOneNfts != playerNft, "You cannot use the same NFT");
        
        ERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);

        openedMatches[matchId].playerTwo = msg.sender;
        openedMatches[matchId].nfts.playerTwoNfts = nftAddress;
        openedMatches[matchId].nfts.playerTwoNftId = nftId;
        openedMatches[matchId].status = MatchStatus.Closed;

        emit JoinedMatch(openedMatches[matchId].playerOne, openedMatches[matchId].playerTwo);
    }

   function requestRandomWords(uint256 number) public  {
        fulfillRandomWords(1, number);
    }

    function fulfillRandomWords(uint256 requestId, uint256 randomNumber) public {
        uint256 winner = randomNumber % 2 + 1;

        if (winner == 1) {
            ERC721(openedMatches[requestId].nfts.playerOneNfts).transferFrom(address(this), openedMatches[requestId].playerOne, openedMatches[requestId].nfts.playerOneNftId);
            ERC721(openedMatches[requestId].nfts.playerTwoNfts).transferFrom(address(this), openedMatches[requestId].playerOne, openedMatches[requestId].nfts.playerTwoNftId);
            emit MatchClosed(openedMatches[requestId].playerOne, openedMatches[requestId].playerTwo, block.timestamp);
        } else {
            ERC721(openedMatches[requestId].nfts.playerOneNfts).transferFrom(address(this), openedMatches[requestId].playerTwo, openedMatches[requestId].nfts.playerOneNftId);
            ERC721(openedMatches[requestId].nfts.playerTwoNfts).transferFrom(address(this), openedMatches[requestId].playerTwo, openedMatches[requestId].nfts.playerTwoNftId);
            emit MatchClosed(openedMatches[requestId].playerTwo, openedMatches[requestId].playerOne, block.timestamp);
        }
    }
}