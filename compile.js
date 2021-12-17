const path = equire("path");
const fs = require("fs");
const solc = require("solc");

const TalaxTokenPath = path.resolve(__dirname,'contracts',"TalaxToken.sol");
const source = fs.readFileSync(TalaxTokenPath,'utf8');

module.exports = solc.compile(source,1).contracts[":TalaxToken"];