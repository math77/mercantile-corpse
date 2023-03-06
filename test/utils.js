//import fs from "fs";

const fs = require("fs");

const saveSVG = (title, svgString) => {
  fs.writeFileSync("./test/svg-samples/"+title+".svg", svgString);
}

const extractToSVG = (uri) => {
  const encodedJSON = uri.substr('data:application/json;base64,'.length);
  const decodedJSON = Buffer.from(encodedJSON, 'base64').toString('utf8');

  const json = JSON.parse(decodedJSON);

  const bff = json["image"].substr('data:image/svg+xml;base64,'.length);
  const txx = Buffer.from(bff, 'base64').toString('utf8');

  return txx;
}

const getRandom = (min, max) => {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1) + min); // The maximum is inclusive and the minimum is inclusive
}

module.exports = {
  saveSVG,
  extractToSVG,
  getRandom
}