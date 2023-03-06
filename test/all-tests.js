const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

const help = require("./utils");

describe("Mint test", function () {

  let verseContract, poemsContract;


  before("deploy the contract's instances first", async function () {

    //DEPLOY METADATA
    const corpseMetadataFactory = await hre.ethers.getContractFactory('MercantileCorpseMetadata');
    const metadataContract = await corpseMetadataFactory.deploy();
    await metadataContract.deployed();

    //DEPLOY VERSES CONTRACT
    const verseFactory = await hre.ethers.getContractFactory('MercantileCorpseVerse');
    verseContract = await verseFactory.deploy(metadataContract.address);
    await verseContract.deployed();

    //DEPLOY MAIN CONTRACT
    const poemsFactory = await hre.ethers.getContractFactory('MercantileCorpse');
    poemsContract = await poemsFactory.deploy(metadataContract.address, verseContract.address);
    await poemsContract.deployed();

    let txnSet = await verseContract.setMercantileCorpseContract(poemsContract.address);
    await txnSet.wait();

    [owner, acc1, acc2, acc3] = await ethers.getSigners();

    await new Promise((r) => setTimeout(r, 700));

  });

  it("Mint 4 verses to account 1", async function () {
    const toPay = String(0.005 * 4);

    //await expect(verseContract.connect(acc1).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");

    await expect(verseContract.connect(acc1).mint(4)).to.emit(verseContract, "VersesMinted");

  });

  it("Mint 3 verses to account 2", async function () {
    const toPay = String(0.005 * 3);

    //await expect(verseContract.connect(acc2).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");
      
    await expect(verseContract.connect(acc2).mint(3)).to.emit(verseContract, "VersesMinted")

  });

  it("Mint 4 verses to account 3", async function () {
    const toPay = String(0.005 * 3);

    //await expect(verseContract.connect(acc2).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");
      
    await expect(verseContract.connect(acc3).mint(4)).to.emit(verseContract, "VersesMinted")

  });

  it("Add text to verses from account 1", async function () {

    const tverses = [
      "God is so potent, as His power can Draw out of bad a sovereign good",
      "It is the hour to be drunken! Lest you be the martyred slaves of Time",
      "Astronomy forces our soul to look up and take us from our world to another.",
      "The fact that life evolved out of nearly nothing, some 10 billion years after the universe evolved out of literally nothing"
    ];

    for (let i = 0; i < 4; i++) {
      await expect(verseContract.connect(acc1).addTextToBlankVerse(i+1, tverses[i])).to.emit(verseContract, "TextAddedToVerse").withArgs(i+1);
    }

  });

  it("Add text to verses from account 2", async function () {

    const tverses = [
      "The Brain is wider than the Sky",
      "A blossom pink, a blossom blue, Make all there is in love so true.",
      "What a piece of work is man, How noble in reason, how infinite in faculty",
      "The ultimate goal of all art is the union between the material and the spiritual."
    ];

    for (let i = 0; i < 3; i++) {

      await expect(verseContract.connect(acc2).addTextToBlankVerse(i+5, tverses[i])).to.emit(verseContract, "TextAddedToVerse").withArgs(i+5);
    }
    
  });

  it("Add text to verses from account 3", async function () {

    const tverses = [
      "Turn around and face the stranger",
      "Freedom is the right of all sentient beings.",
      "Art is never finished, only abandoned.",
      "Obsessive people make great art."
    ];

    for (let i = 0; i < 4; i++) {

      await expect(verseContract.connect(acc3).addTextToBlankVerse(i+8, tverses[i])).to.emit(verseContract, "TextAddedToVerse").withArgs(i+8);
    }
    
  });


  it("Transfer verse from account 2 to account 1", async function () {

    await verseContract.connect(acc2).transferFrom(acc2.address, acc1.address, 6);

    //await expect(verseContract.connect(acc2).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");
    
  });

  it("Transfer verse from account 1 to account 3", async function () {

    await verseContract.connect(acc1).transferFrom(acc1.address, acc3.address, 2);

    //await expect(verseContract.connect(acc2).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");
    
  });

  it("Transfer verse from account 2 to account 3", async function () {

    await verseContract.connect(acc2).transferFrom(acc2.address, acc3.address, 7);

    //await expect(verseContract.connect(acc2).mint({value: ethers.utils.parseEther(toPay)}, 4)).to.emit(verseContract, "VersesMinted");
    
  });

  it("Should return uri from verse 3", async function () {
    let tokenUri = await verseContract.tokenURI(3);

    console.log("VERSE 3: ", tokenUri);

    let svgStr = help.extractToSVG(tokenUri);

    help.saveSVG("verse3", svgStr);
  });

  it("Create a poem from account 1", async function () {

    const versesIds = [1, 3, 4, 6];

    await expect(poemsContract.connect(acc1).createPoem(versesIds, "A poem of test")).to.emit(poemsContract, "PoemCreated");

  });

  it("Create a poem from account 3", async function () {

    const versesIds = [2, 7, 8];
    //const versesIds = [9, 10, 11];

    await expect(poemsContract.connect(acc3).createPoem(versesIds, "A wonderful poem?")).to.emit(poemsContract, "PoemCreated");

  });

  it("Should return uri from poem 1", async function () {
    let tokenUri = await poemsContract.tokenURI(1);

    console.log("POEM 1: ", tokenUri);

    let svgStr = help.extractToSVG(tokenUri);

    help.saveSVG("poem1", svgStr);
  });

  it("Should return uri from poem 2", async function () {
    let tokenUri = await poemsContract.tokenURI(2);

    console.log("POEM 2: ", tokenUri);

    let svgStr = help.extractToSVG(tokenUri);

    help.saveSVG("poem2", svgStr);
  });

});
