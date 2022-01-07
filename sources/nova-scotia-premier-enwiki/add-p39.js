const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, startdate, enddate) => {
  qualifier = { }
  if(startdate) qualifier['P580'] = startdate
  if(enddate)   qualifier['P582'] = enddate

  return {
    id,
    claims: {
      P39: {
        value: meta.position,
        qualifiers: qualifier,
        references: { P4656: meta.source }
      }
    }
  }
}
