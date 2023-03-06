//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import {IMercantileCorpse} from "./IMercantileCorpse.sol";

interface IMercantileCorpseMetadata {
  function tokenURI(
    uint256 tokenId,
    bool isVerse,
    IMercantileCorpse.Verse memory verse,
    IMercantileCorpse.Poem memory poem
  ) external view returns (string memory);
}
