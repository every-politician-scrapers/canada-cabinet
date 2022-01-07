const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  let cabinet = meta.cabinet.parent ? `UNION { ?item wdt:P31 wd:${meta.cabinet.parent} }` : '';
  let govment = meta.cabinet.government ? `UNION { ?item wdt:P31 wd:${meta.cabinet.government} }` : '';

  return `SELECT DISTINCT ?ordinal ?item ?itemLabel
                  ?inception ?inceptionPrecision
                  ?startTime ?startTimePrecision
                  ?abolished ?abolishedPrecision
                  ?endTime   ?endTimePrecision
                  ?replaces ?replacesLabel ?replacedBy ?replacedByLabel
                  ?follows ?followsLabel ?followedBy ?followedByLabel
  WHERE {
    { ?item wdt:P31/wdt:P279* wd:Q640506 ; wdt:P1001 wd:${meta.jurisdiction.id} }
    ${cabinet}
    ${govment}

    OPTIONAL { ?item p:P31/pq:P1545 ?ordinal }
    OPTIONAL { ?item p:P571 [ a wikibase:BestRank ; psv:P571 [wikibase:timeValue ?inception ; wikibase:timePrecision ?inceptionPrecision] ] }
    OPTIONAL { ?item p:P580 [ a wikibase:BestRank ; psv:P580 [wikibase:timeValue ?startTime ; wikibase:timePrecision ?startTimePrecision] ] }
    OPTIONAL { ?item p:P576 [ a wikibase:BestRank ; psv:P576 [wikibase:timeValue ?abolished ; wikibase:timePrecision ?abolishedPrecision] ] }
    OPTIONAL { ?item p:P582 [ a wikibase:BestRank ; psv:P582 [wikibase:timeValue ?endTime   ; wikibase:timePrecision ?endTimePrecision]   ] }

    OPTIONAL { ?item wdt:P1365 ?replaces     }
    OPTIONAL { ?item wdt:P1366 ?replacedBy   }
    OPTIONAL { ?item wdt:P155 ?follows       }
    OPTIONAL { ?item wdt:P156 ?followedBy    }

    BIND(COALESCE(?inception, ?startTime) AS ?start)

    SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
  }
  # ${new Date().toISOString()}
  ORDER BY ?start ?item`
}
