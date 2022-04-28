module.exports = function () {
  return `SELECT DISTINCT ?province ?provinceLabel ?position ?positionLabel ?person ?personLabel ?start
         (STRAFTER(STR(?held), '/statement/') AS ?psid)
  WHERE {
    ?position wdt:P279+ wd:Q2505921 .
    OPTIONAL { ?position wdt:P1001 ?province }

    OPTIONAL {
      ?person wdt:P31 wd:Q5 ; p:P39 ?held .
      ?held ps:P39 ?position ; pq:P580 ?start .
      FILTER NOT EXISTS { ?held pq:P582 ?end }
    }

    SERVICE wikibase:label { bd:serviceParam wikibase:language "en".  }
  }
  # ${new Date().toISOString()}
  ORDER BY ?provinceLabel ?start`
}
