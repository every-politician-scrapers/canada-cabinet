module.exports = (...positions) => {
  positions = positions.map(value => `wd:${value}`).join(' ')

  return `SELECT DISTINCT ?person ?position ?start ?ps
    WITH {
      SELECT DISTINCT ?person ?position ?startNode ?ps
      WHERE {
          VALUES ?position { ${positions} }
          ?person wdt:P31 wd:Q5 ; p:P39 ?ps .
          ?ps ps:P39 ?position .
          FILTER NOT EXISTS { ?ps wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?ps pq:P582 ?p39end }
          OPTIONAL { ?ps pqv:P580 ?p39start }
          OPTIONAL {
            ?ps pq:P5054 ?cabinet .
            OPTIONAL { ?cabinet p:P571 [ a wikibase:BestRank ; psv:P571 ?cabinetInception ] }
            OPTIONAL { ?cabinet p:P580 [ a wikibase:BestRank ; psv:P580 ?cabinetStart ] }
            OPTIONAL { ?cabinet wdt:P576|wdt:P582 ?cabinetEnd }
          }
          OPTIONAL {
            ?ps pq:P2937 ?term .
            OPTIONAL { ?term p:P571 [ a wikibase:BestRank ; psv:P571 ?termInception ] }
            OPTIONAL { ?term p:P580 [ a wikibase:BestRank ; psv:P580 ?termStart ] }
            OPTIONAL { ?term wdt:P576|wdt:P582 ?termEnd }
          }
          BIND(COALESCE(?p39start, ?cabinetInception, ?cabinetStart, ?termStart) AS ?startNode)
          BIND(COALESCE(?p39end, ?cabinetEnd, ?termEnd) AS ?end)
          FILTER(BOUND(?startNode) && (!BOUND(?end) || ?end > NOW()))
      }
    } AS %statements
    WHERE {
      INCLUDE %statements .
      ?startNode wikibase:timeValue ?startV ; wikibase:timePrecision ?startP .
      FILTER (?startV < NOW())
      BIND (
        COALESCE(
          IF(?startP = 11, SUBSTR(STR(?startV), 1, 10), 1/0),
          IF(?startP = 10, SUBSTR(STR(?startV), 1, 7), 1/0),
          IF(?startP = 9,  SUBSTR(STR(?startV), 1, 4), 1/0),
          IF(?startP = 8,  CONCAT(SUBSTR(STR(?startV), 1, 4), "s"), 1/0),
          ""
        ) AS ?start
      )
    }
    # ${new Date().toISOString()}
    ORDER BY ?position ?person ?start ?ps`
}

