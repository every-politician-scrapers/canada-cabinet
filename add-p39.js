const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, position, startdate) => {
  qualifier = {
    P580: meta.cabinet.start,
    P5054: meta.cabinet.id,
  }

  if(startdate)      qualifier['P580']  = startdate

  return {
    id,
    claims: {
      P39: {
        value: position,
        qualifiers: qualifier,
      }
    }
  }
}
