//SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract RealEstate is ERC721URIStorage, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;

    address private manager;
    uint256 private check;

    struct PropertyNFT {
        uint256 nftID;
        string nftURI;
        address nftCreater;
        address nftOwner;
        uint256 nftPrice;
        bool nftStatus;
    }

    PropertyNFT[] properties;

    constructor() ERC721("Real Estate", "RLST") {
        manager = msg.sender;
    }

    function getManager() external view returns(address){
        return manager;
    }

    modifier OnlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can call this function!"
        );
        _;
    }

    function sellNFT(string memory tokenURI, uint256 price)
        external
        whenNotPaused
    {
        require(msg.sender != manager, "Manager cannot sell!");
        tokenId.increment();
        uint256 newTokenId = tokenId.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        properties.push(
            PropertyNFT(
                newTokenId,
                tokenURI,
                msg.sender,
                msg.sender,
                price,
                false
            )
        );
    }

    function indexof(uint256 TokenId) public view returns(uint256){
        for(uint256 i=0;i<properties.length;i++){
            if(properties[i].nftID==TokenId){
                 return i;
            }
        }
        return properties.length - properties.length -1;
    }

    function buyNFT(uint256 TokenId) external payable whenNotPaused {
        require(msg.sender != manager, "Manager cannot buy!");
        uint256 index = indexof(TokenId);
        require(index>=0, "Token does not exist!");
        require(
            msg.sender != properties[index].nftOwner,
            "You are the owner of this NFT!"
        );
        require(
            properties[index].nftStatus == false,
            "This NFT has been sold already!"
        );
        require(
            msg.value >= properties[index].nftPrice,
            "Insufficient funds!"
        );
        payable(msg.sender).transfer(
            msg.value - properties[index].nftPrice
        );
        address owner = ownerOf(TokenId);
        payable(owner).transfer(properties[index].nftPrice);
        _transfer(owner, msg.sender, TokenId);
        PropertyNFT storage object = properties[index];
        object.nftOwner = msg.sender;
        object.nftStatus = true;
        check++;
    }

    function getNFTS() external view returns (PropertyNFT[] memory) {
        return properties;
    }

    function reset() external OnlyManager{
        require(properties.length>0,"There are no properties in the Real Estate market!");
        require(check==properties.length,"Not all properties have been sold yet!");
            delete properties;
            check=0;
    }

    function pause() external OnlyManager {
        _pause();
    }

    function unpause() external OnlyManager {
        _unpause();
    }
}

//"Naman",45000000000000000000
//"Madhur",50000000000000000000
//"Neha",70000000000000000000
