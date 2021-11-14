module.exports = (...positions) => {
  positions = positions.map(value => `wd:${value}`).join(' ')

  return `SELECT DISTINCT ?person ?position ?start ?ps
    WHERE {
      VALUES ?position { ${positions} }
      ?person wdt:P31 wd:Q5 ; p:P39 ?ps .
      ?ps ps:P39 ?position .
      FILTER NOT EXISTS { ?ps wikibase:rank wikibase:DeprecatedRank }
      FILTER NOT EXISTS { ?ps pq:P582 [] }
      OPTIONAL { ?ps pq:P580 ?p39start }
      OPTIONAL {
        ?ps pq:P5054 ?cabinet .
        OPTIONAL { ?cabinet wdt:P571|wdt:P580 ?cabinetStart }
        OPTIONAL { ?cabinet wdt:P576|wdt:P582 ?cabinetEnd }
      }
      OPTIONAL {
        ?ps pq:P2937 ?term .
        OPTIONAL { ?term wdt:P571|wdt:P580 ?termStart }
        OPTIONAL { ?term wdt:P576|wdt:P582 ?termEnd }
      }
      BIND(COALESCE(?p39start, ?cabinetStart, ?termStart) AS ?start)
      BIND(COALESCE(?cabinetEnd, ?termEnd) AS ?end)
      FILTER(BOUND(?start) && (!BOUND(?end) || ?end > NOW()))
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }
    # ${new Date().toISOString()}
    ORDER BY ?positionLabel ?personLabel ?start`
}

