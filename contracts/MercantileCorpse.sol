//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {MercantileCorpseVerse} from "./MercantileCorpseVerse.sol";
import {IMercantileCorpseMetadata} from "./interfaces/IMercantileCorpseMetadata.sol";
import {IMercantileCorpse} from "./interfaces/IMercantileCorpse.sol";

import {SSTORE2} from "./libraries/SSTORE2.sol";

import "hardhat/console.sol";

contract MercantileCorpse is IMercantileCorpse, ERC721, Ownable, ReentrancyGuard {

  uint256 private _tokenId;
  
  address immutable metadataContractAddr;

  MercantileCorpseVerse mercantileVerseContract;

  mapping(uint256 tokenId => Poem poem) private _poems;


  event PoemCreated(uint256 indexed tokenId);
  event TitleAdded(uint256 indexed poemId);

  error InvalidAmountOfVerses();
  error NotTokenOwner();


  constructor(address metadataContract, MercantileCorpseVerse corpseVerse) ERC721("MercantileCorpsePoem", "POEM") Ownable() {
    metadataContractAddr = metadataContract;
    mercantileVerseContract = corpseVerse;
  }
  

  receive() external payable {}
  fallback() external payable {}

  function createPoem(uint256[] calldata versesIds, string calldata title) external payable {
    if(versesIds.length < 3 || versesIds.length > 6) revert InvalidAmountOfVerses();

    mercantileVerseContract.verifyOwnershipOfTokens(msg.sender, versesIds);
    mercantileVerseContract.hasBlankVerse(versesIds);
    mercantileVerseContract.verifyCreators(msg.sender, versesIds);


    _poems[++_tokenId].creator = msg.sender;
    _poems[_tokenId].title = title;

    for(uint256 i; i < versesIds.length;) {
      uint256 verseId = versesIds[i];

      _poems[_tokenId].verses.push(mercantileVerseContract.getVerse(verseId));

      mercantileVerseContract.burnVerse(verseId);

      unchecked{i++;}
    }

    _mint(msg.sender, _tokenId);

    emit PoemCreated(_tokenId);
  }

  function setPoemTitle(uint256 poemId, string calldata title) external {
    if(ownerOf(poemId) != msg.sender) revert NotTokenOwner();

    _poems[poemId].title = title;

    emit TitleAdded(poemId);
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    require(_exists(tokenId), "Token does not exist.");

    Verse memory verse;

    return IMercantileCorpseMetadata(metadataContractAddr).tokenURI(tokenId, false, verse, _poems[tokenId]);
  }
}
