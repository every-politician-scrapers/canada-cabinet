const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?ordinal ?item ?itemLabel
                  ?inception ?inceptionPrecision
                  ?startTime ?startTimePrecision
                  ?abolished ?abolishedPrecision
                  ?endTime   ?endTimePrecision
                  ?isa ?isaLabel ?parent ?parentLabel
                  ?replaces ?replacesLabel ?replacedBy ?replacedByLabel
                  ?follows ?followsLabel ?followedBy ?followedByLabel
  WHERE {
    ?item wdt:P31/wdt:P279* wd:Q640506 ; wdt:P1001 wd:${meta.jurisdiction.id} .
    OPTIONAL { ?item p:P31/pq:P1545 ?ordinal }
    OPTIONAL { ?item p:P571 [ a wikibase:BestRank ; psv:P571 [wikibase:timeValue ?inception ; wikibase:timePrecision ?inceptionPrecision] ] }
    OPTIONAL { ?item p:P580 [ a wikibase:BestRank ; psv:P580 [wikibase:timeValue ?startTime ; wikibase:timePrecision ?startTimePrecision] ] }
    OPTIONAL { ?item p:P576 [ a wikibase:BestRank ; psv:P576 [wikibase:timeValue ?abolished ; wikibase:timePrecision ?abolishedPrecision] ] }
    OPTIONAL { ?item p:P582 [ a wikibase:BestRank ; psv:P582 [wikibase:timeValue ?endTime   ; wikibase:timePrecision ?endTimePrecision]   ] }
    OPTIONAL { ?item wdt:P580 ?startTime     }
    OPTIONAL { ?item wdt:P576 ?abolished     }
    OPTIONAL { ?item wdt:P582 ?endTime       }
    OPTIONAL { ?item wdt:P31 ?isa            }
    OPTIONAL { ?item wdt:P279 ?parent        }
    OPTIONAL { ?item wdt:P1365 ?replaces     }
    OPTIONAL { ?item wdt:P1366 ?replacedBy   }
    OPTIONAL { ?item wdt:P155 ?follows       }
    OPTIONAL { ?item wdt:P156 ?followedBy    }

    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
  }
  ORDER BY ?inception ?isa ?parent`
}
