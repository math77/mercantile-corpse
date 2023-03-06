//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

interface IMercantileCorpse {

  struct Verse {
    address pointerToContent;
    address creator;
  }

  struct Poem {
    Verse[] verses;
    address creator;
    string title;
  }
}