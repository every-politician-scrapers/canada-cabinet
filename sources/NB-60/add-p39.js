const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, label, party, riding, startdate, enddate) => {
  qualifier = { P2937: meta.term }
  if(party)     qualifier['P4100'] = party
  if(riding)    qualifier['P768']  = riding
  if(startdate) qualifier['P580']  = startdate
  if(enddate)   qualifier['P582']  = enddate

  return {
    id,
    claims: {
      P39: {
        value: meta.position,
        qualifiers: qualifier,
        references: {
          P4656: meta.source,
          P813: new Date().toISOString().split('T')[0],
          P1810: label,
        }
      }
    }
  }
}
