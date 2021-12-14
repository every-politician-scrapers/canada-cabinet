module.exports = (...positions) => {
  positions = positions.map(value => `wd:${value}`).join(' ')

  return `SELECT DISTINCT ?person ?position ?start ?end ?prev ?next ?ps
    WITH {
      SELECT DISTINCT ?person ?position ?startNode ?endNode ?ps
      WHERE {
          VALUES ?position { ${positions} }
          ?person wdt:P31 wd:Q5 ; p:P39 ?ps .
          ?ps ps:P39 ?position .
          FILTER NOT EXISTS { ?ps wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?ps pqv:P580 ?p39start }
          OPTIONAL { ?ps pqv:P582 ?p39end }
          OPTIONAL {
            ?ps pq:P5054 ?cabinet .
            OPTIONAL { ?cabinet p:P571 [ a wikibase:BestRank ; psv:P571 ?cabinetInception ] }
            OPTIONAL { ?cabinet p:P580 [ a wikibase:BestRank ; psv:P580 ?cabinetStart ] }
            OPTIONAL { ?cabinet p:P576 [ a wikibase:BestRank ; psv:P576 ?cabinetAbolished ] }
            OPTIONAL { ?cabinet p:P582 [ a wikibase:BestRank ; psv:P582 ?cabinetEnd ] }
          }
          OPTIONAL {
            ?ps pq:P2937 ?term .
            OPTIONAL { ?term p:P571 [ a wikibase:BestRank ; psv:P571 ?termInception ] }
            OPTIONAL { ?term p:P580 [ a wikibase:BestRank ; psv:P580 ?termStart ] }
            OPTIONAL { ?term p:P576 [ a wikibase:BestRank ; psv:P576 ?termAbolished ] }
            OPTIONAL { ?term p:P582 [ a wikibase:BestRank ; psv:P582 ?termEnd ] }
          }
          wd:Q18354756 p:P580/psv:P580 ?farFuture .

          BIND(COALESCE(?p39start, ?cabinetInception, ?cabinetStart, ?termInception, ?termStart) AS ?startNode)
          BIND(COALESCE(?p39end,   ?cabinetAbolished, ?cabinetEnd,   ?termAbolished, ?termEnd, ?farFuture) AS ?endNode)
          FILTER(BOUND(?startNode))
      }
    } AS %statements
    WHERE {
      INCLUDE %statements .
      ?startNode wikibase:timeValue ?startV ; wikibase:timePrecision ?startP .
      ?endNode   wikibase:timeValue ?endV   ; wikibase:timePrecision ?endP .
      FILTER (?startV < NOW() && YEAR(?endV) >= 2000)

      OPTIONAL { ?ps pq:P1365 ?prev }
      OPTIONAL { ?ps pq:P1366 ?next }

      BIND (
        COALESCE(
          IF(?startP = 11, SUBSTR(STR(?startV), 1, 10), 1/0),
          IF(?startP = 10, SUBSTR(STR(?startV), 1, 7), 1/0),
          IF(?startP = 9,  SUBSTR(STR(?startV), 1, 4), 1/0),
          IF(?startP = 8,  CONCAT(SUBSTR(STR(?startV), 1, 4), "s"), 1/0),
          ""
        ) AS ?start
      )

      BIND (
        COALESCE(
          IF(?endP = 11, SUBSTR(STR(?endV), 1, 10), 1/0),
          IF(?endP = 10, SUBSTR(STR(?endV), 1, 7), 1/0),
          IF(?endP = 9,  SUBSTR(STR(?endV), 1, 4), 1/0),
          IF(?endP = 8,  CONCAT(SUBSTR(STR(?endV), 1, 4), "s"), 1/0),
          ""
        ) AS ?end
      )
    }
    # ${new Date().toISOString()}
    ORDER BY ?position ?person ?start ?ps`
}

