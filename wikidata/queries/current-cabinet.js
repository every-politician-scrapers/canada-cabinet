const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?item ?itemLabel ?position ?positionLabel ?start
               (STRAFTER(STR(?held), '/statement/') AS ?psid)
        WHERE {
          # Positions currently in the cabinet
          ?position p:P361 ?ps .
          ?ps ps:P361 wd:${meta.cabinet.parent} .
          FILTER NOT EXISTS { ?ps pq:P582 [] }

          # Who currently holds those positions
          ?item wdt:P31 wd:Q5 ; p:P39 ?held .
          FILTER NOT EXISTS { ?item wdt:P570 [] }

          ?held ps:P39 ?position ; pq:P580 ?start .
          OPTIONAL { ?held pq:P582 ?end }

          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          FILTER (?start < NOW())
          FILTER (!BOUND(?end) || ?end > NOW())

          SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
        }
        # ${new Date().toISOString()}
        ORDER BY ?item ?position ?start ?psid`
}
