//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {MercantileCorpse} from "./MercantileCorpse.sol";

import {IMercantileCorpseMetadata} from "./interfaces/IMercantileCorpseMetadata.sol";
import {IMercantileCorpse} from "./interfaces/IMercantileCorpse.sol";

import {SSTORE2} from "./libraries/SSTORE2.sol";

import "hardhat/console.sol";

contract MercantileCorpseVerse is ERC721, IMercantileCorpse, Ownable {

  uint256 private _tokenId;

  uint256 private constant VERSE_MAX_SUPPLY = 5000;
  uint256 private constant MAX_VERSE_BY_MINT = 10;
  uint256 private constant MINT_PRICE_BY_VERSE = 0.005 ether;

  MercantileCorpse private _mercantileCorpseContract;

  address private immutable _metadataContractAddr;


  mapping(uint256 tokenId => Verse verse) private _verses;


  event TextAddedToVerse(uint256 indexed tokenId);
  event VersesMinted(uint256 indexed lastTokenId);

  error InvalidCaller();
  error ETHSentInsufficient();
  error ExceededMaxQuantity();
  error MaxSupplyReached();
  error NotTheTokenOwner();
  error AlreadyFilled();

  error BlankVerseNotAllowed();
  error NeedOneTokenFromMarket();


  modifier onlyCorpseContract() { 
    if(msg.sender != address(_mercantileCorpseContract)) revert InvalidCaller(); 
    _; 
  }

  constructor(address metadataContract) ERC721("MercantileCorpseVerse", "VERSE") Ownable() {
    metadataContractAddr = metadataContract;
  }

  //mint blank verse
  function mint(uint256 quantity) external payable {
    if(_tokenId + quantity > VERSE_MAX_SUPPLY) revert MaxSupplyReached();
    if(quantity > MAX_VERSE_BY_MINT) revert ExceededMaxQuantity();
    if(quantity * MINT_PRICE_BY_VERSE < msg.value) revert ETHSentInsufficient();

    for(uint256 i; i < quantity;) {
      unchecked {
        _mint(msg.sender, ++_tokenId);
        i++;
      }

      _verses[_tokenId] = Verse({pointerToContent: address(0), creator: address(0)});
    }

    emit VersesMinted(_tokenId);
  }

  function addTextToBlankVerse(uint256 tokenId, string calldata text) external {
    if(ownerOf(tokenId) != msg.sender) revert NotTheTokenOwner();
    if(_verses[tokenId].pointerToContent != address(0)) revert AlreadyFilled();

    _verses[tokenId].pointerToContent = SSTORE2.write(bytes(text));
    _verses[tokenId].creator = msg.sender;

    emit TextAddedToVerse(tokenId);
  }

  function hasBlankVerse(uint256[] calldata versesIds) external view {
    for(uint256 i; i < versesIds.length;) {
      uint256 verseId = versesIds[i];

      if(_verses[verseId].pointerToContent == address(0)) {
        revert BlankVerseNotAllowed();
      }

      unchecked{i++;}
    }
  }

  function verifyCreators(address owner_, uint256[] calldata versesIds) external view {
    
    uint256 leastOneByOtherWallet;

    for(uint256 i; i < versesIds.length;) {
      uint256 verseId = versesIds[i];

      if(_verses[verseId].creator != owner_) {
        leastOneByOtherWallet++;
      }

      unchecked{i++;}
    }

    if(leastOneByOtherWallet == 0) {
      revert NeedOneTokenFromMarket();
    }
  }

  function verifyOwnershipOfTokens(address owner_, uint256[] calldata versesIds) external view {
    for(uint256 i; i < versesIds.length;) {
      address owner = ownerOf(versesIds[i]);

      if(owner != owner_) {
        revert NotTheTokenOwner();
      }

      unchecked {i++;}
    }
  }

  function burnVerse(uint256 verseId) external onlyCorpseContract {
    _burn(verseId);
  }

  function getVerse(uint256 verseId) external view returns(Verse memory) {
    return _verses[verseId];
  }

  function tokenURI(uint256 tokenId) public view override returns(string memory) {
    require(_exists(tokenId), "Token does not exist.");

    Poem memory poem;

    return IMercantileCorpseMetadata(_metadataContractAddr).tokenURI(tokenId, true, _verses[tokenId], poem);
  }

  function setMercantileCorpseContract(MercantileCorpse corpseContract) external onlyOwner {
    _mercantileCorpseContract = corpseContract;
  }

}
