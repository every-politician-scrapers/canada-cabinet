#!/bin/sh

TMPFILE=$(mktemp)
HOLDERS=$(mktemp)
RAWBIOS=$(mktemp)
BIO_CSV=$(mktemp)
ENUM_PS=$(mktemp)
EXTD_21=$(mktemp)

PERSON_PROPS="en,P31,P18,P21,P27,P1559,P1477,P2561,P735,P734,P1950,P5056,P2652,P569,P19,P570,P22,P25,P26,P40,P3373,P39,P69,P511,P102,P3602,sitelinks"

# Holders of each wanted position
qsv select position wikidata/wanted-positions.csv |
  qsv behead |
  xargs wd sparql pcb/holders.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $HOLDERS

# Biographical info for officeholders
qsv select person $HOLDERS |
  qsv dedup |
  qsv sort |
  qsv behead |
  wd data --props $PERSON_PROPS --simplify --time-converter simple-day --keep qualifiers,nontruthy,ranks,nondeprecated,richvalues > $RAWBIOS

echo "id,name,gender,dob,dobp,dod,dodp,image,enwiki" > $BIO_CSV
jq -r 'def highest(array): (array | sort_by(.rank) | reverse | first.value);
  [
    .id,
    .labels.en,
    highest(.claims.P21),
    if highest(.claims.P569).precision >= 9 then highest(.claims.P569).time else null end,
    highest(.claims.P569).precision,
    highest(.claims.P570).time,
    highest(.claims.P570).precision,
    highest(.claims.P18),
    (try (.sitelinks.enwiki) catch null)
  ] | @csv' $RAWBIOS |
  sed -e 's/Q6581097/male/' -e 's/Q6581072/female/' -e 's/Q1052281/female/' >> $BIO_CSV

# TODO: other positions
# TODO: relations

# Generate holders21.csv, keeping position order from wanted-positions
qsv enum wikidata/wanted-positions.csv > $ENUM_PS
qsv join position $ENUM_PS position $HOLDERS |
  qsv select index,position,title,person,start,end,prev,next > $TMPFILE
qsv join person $TMPFILE id $BIO_CSV |
  qsv sort -s person |
  qsv sort -s start |
  qsv sort -N -s index |
  qsv select title,name,person,start,end,gender,dob,dod,image,enwiki,prev,next |
  qsv rename position,person,personID,start,end,gender,DOB,DOD,image,enwiki,prev,next > $EXTD_21
qsv select \!prev $EXTD_21 | qsv select \!next | uniq > html/holders21.csv

# Generate current.csv
qsv search -s end -v . html/holders21.csv | qsv select \!end > html/current.csv

# Generate HTML
erb country="$(jq -r .jurisdiction.name meta.json)" csvfile=html/current.csv -r csv -T- pcb/index.erb > html/index.html

# Tests

IFS=$'\n'

warnings=($(qsv join --left-anti title wikidata/wanted-positions.csv position html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## No matches for:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s DOD . html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Dead:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti pid data/wikidata.csv position wikidata/wanted-positions.csv | qsv select pid,position | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## In data/wikidata but not wanted-positions:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti wdid data/wikidata.csv personID html/current.csv | qsv select wdid,name,pid,position | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## In data/wikidata but not current.csv:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv frequency -s position html/current.csv -l 0 | qsv search -s count -v '^1$' | qsv select value,count | qsv table | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Multiple holders:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s dobp -v 11 $BIO_CSV | qsv select id,name,dob,dobp | qsv sort -N -s dobp | qsv table | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Missing/short DOB:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s gender -v male html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Missing gender:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti prev $EXTD_21 personID html/holders21.csv | qsv search -s start "^2" | qsv search -s prev . | qsv select prev,position,start | qsv sort -s start -R | qsv behead | qsv table))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Missing predecessors:"
  printf '* %s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti next $EXTD_21 personID html/holders21.csv | qsv search -s next . | qsv select next,position,end | qsv sort -s end -R | qsv behead | qsv table))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "## Missing successors:"
  printf '* %s\n' "${warnings[@]}"
fi
