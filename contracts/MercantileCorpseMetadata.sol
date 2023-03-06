//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IMercantileCorpseMetadata} from "./interfaces/IMercantileCorpseMetadata.sol";
import {IMercantileCorpse} from "./interfaces/IMercantileCorpse.sol";


import {Base64} from "./libraries/Base64.sol";
import {ToString} from "./libraries/ToString.sol";
import {SSTORE2} from "./libraries/SSTORE2.sol";
import {strings} from "./libraries/strings.sol";


import "hardhat/console.sol";

contract MercantileCorpseMetadata is IMercantileCorpseMetadata, Ownable {
  

  function getVerseText(address pointer) internal view returns (string memory) {
    return string(SSTORE2.read(pointer));
  }

  function getVerseSVG(IMercantileCorpse.Verse memory verse, uint256 tokenId) internal view returns(bytes memory svg) {
    if(verse.pointerToContent != address(0)) {
      svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="0 0 350 450" encoding="UTF-8"><style> #content { -ms-overflow-style: none; scrollbar-width: none; overflow-y: scroll; } #content::-webkit-scrollbar { display: none; } #content { color: black; font: 13px serif; height: 360px; padding: 30px; padding-top: 0; word-spacing: 2px; text-transform: lowercase; text-align: justify; } #decor {font: 12px serif; margin-bottom: -4px; text-align: center; } </style><rect width="350" height="450" fill="#eddcd2" /><foreignObject x="0" y="0" width="350" height="450"><div id="content" xmlns="http://www.w3.org/1999/xhtml"><p>',
        getVerseText(verse.pointerToContent),
        '</p></div></foreignObject></svg>'
      );

    } else {
      svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="0 0 350 450" encoding="UTF-8"><rect width="350" height="450" fill="#eddcd2" /><style>.decor {font: 14px serif; margin-bottom: -4px; text-align: center; }</style><text x="10" y="30">[INSERT THE VERSE HERE.]</text><text x="175" y="440" class="decor">#', 
        ToString.toString(tokenId),
        '</text></svg>'
      );
    }
  }

  
  function getPoemSVG(IMercantileCorpse.Poem memory poem) internal view returns(bytes memory svg) {
    string memory content;

    for(uint256 i; i < poem.verses.length;) {
      content = string(abi.encodePacked(content, "<p class='sentence'>", getVerseText(poem.verses[i].pointerToContent), "</p>"));

      unchecked{i++;}
    }


    svg = abi.encodePacked(
      '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" viewBox="0 0 300 400" encoding="UTF-8"><style> #content { -ms-overflow-style: none; scrollbar-width: none; overflow-y: scroll; } #content::-webkit-scrollbar { display: none; } #content { color: black; font: 11px serif; height: 360px; padding: 30px; padding-top: 15px; word-spacing: 2px; text-transform: lowercase; text-align: justify; } .sentence:first-letter { text-transform: capitalize; } h2 {margin-bottom: 25px;} h2:first-letter { text-transform: capitalize; } </style><rect width="300" height="400" fill="#eddcd2" /><foreignObject x="0" y="0" width="300" height="400"><div id="content" xmlns="http://www.w3.org/1999/xhtml"><h2>',
      poem.title,
      '</h2>',
      content,
      '</div></foreignObject></svg>'
    );
  }
  
  function tokenURI(
    uint256 tokenId,
    bool isVerse,
    IMercantileCorpse.Verse memory verse,
    IMercantileCorpse.Poem memory poem
  ) public view override returns (string memory) {

    bytes memory svgContent;
    string memory attrs;

    if(isVerse) {
      svgContent = getVerseSVG(verse, tokenId);
      attrs = generateAttributes( 
        0, //amount of verses
        verse.creator
      );
    } else {
      svgContent = getPoemSVG(poem);
      attrs = generateAttributes( 
        poem.verses.length, //amount of verses
        poem.creator
      );
    }

    (
      string memory title,
      string memory description
    ) = generateTitleAndDescription(tokenId, isVerse);


    return 
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name": "',
                title,
                '", "description": "', description, '", "image": "data:image/svg+xml;base64,',
                Base64.encode(svgContent),
                '", "attributes": ',
                attrs,
                '}'
              )
            )
          )
        )
      );
  }

  function generateTitleAndDescription(uint256 tokenId, bool isVerse) internal view returns(string memory title, string memory description) {
    if(isVerse) {
      title = string(abi.encodePacked('MercantileCorpse Verse #', ToString.toString(tokenId)));
      description = 'A verse.';
    } else {
      title = string(abi.encodePacked('MercantileCorpse Poem #', ToString.toString(tokenId)));
      description = 'A poem.';
    }
  }

  function generateAttributes(
    uint256 amountOfVerses,
    address creator
  ) internal view returns (string memory attrs) {

    if(amountOfVerses == 0) {
      attrs = string(abi.encodePacked(
        '[{"trait_type":"Created by", "value":"',
        ToString.toHexString(creator),
        '"}]'
      ));
    } else {
      attrs = string(abi.encodePacked(
        '[{"trait_type":"Amount of verses", "value":"',
        ToString.toString(amountOfVerses),
        '"}, {"trait_type":"Created by", "value":"',
        ToString.toHexString(creator),
        '"}]'
      ));
    }
  }
}