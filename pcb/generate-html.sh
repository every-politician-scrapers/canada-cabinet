#!/bin/sh

TMPFILE=$(mktemp)
HOLDERS=$(mktemp)
RAWBIOS=$(mktemp)
BIO_CSV=$(mktemp)

PERSON_PROPS="en,P31,P18,P21,P27,P1559,P1477,P2561,P735,P734,P1950,P5056,P2652,P569,P19,P570,P22,P25,P26,P40,P3373,P39,P69,P511,P102,P3602,sitelinks"

# Current holders of each wanted position
qsv select position wikidata/wanted-positions.csv |
  qsv behead |
  xargs wd sparql pcb/holders.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $HOLDERS

# Biographical info for current officeholders
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
  sed -e 's/Q6581097/male/' -e 's/Q6581072/female/' >> $BIO_CSV

# TODO: other positions
# TODO: relations

# Generate current.csv
qsv join position wikidata/wanted-positions.csv position $HOLDERS |
  qsv select position,title,person,start > $TMPFILE
qsv join person $TMPFILE id $BIO_CSV |
  qsv select title,name,person,start,gender,dob,dod,image,enwiki |
  qsv rename position,person,personID,start,gender,DOB,DOD,image,enwiki > html/current.csv

# Generate HTML
erb country="$(jq -r .jurisdiction.name meta.json)" csvfile=html/current.csv -r csv -T- pcb/index.erb > html/index.html

# Tests

IFS=$'\n'

warnings=($(qsv join --left-anti title wikidata/wanted-positions.csv position html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "No matches for:"
  printf '\t%s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s DOD . html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "Dead:"
  printf '\t%s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti pid data/wikidata.csv position wikidata/wanted-positions.csv | qsv select pid,position | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "In data/wikidata but not wanted-positions:"
  printf '\t%s\n' "${warnings[@]}"
fi

warnings=($(qsv join --left-anti wdid data/wikidata.csv personID html/current.csv | qsv select wdid,name,pid,position | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "In data/wikidata but not current.csv:"
  printf '\t%s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s dobp -v 11 $BIO_CSV | qsv select id,name,dob,dobp | qsv sort -N -s dobp | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "Missing/short DOB:"
  printf '\t%s\n' "${warnings[@]}"
fi

warnings=($(qsv search -s gender -v male html/current.csv | qsv behead))
if [ ${#warnings[@]} -gt 0 ]; then
  echo "Missing gender:"
  printf '\t%s\n' "${warnings[@]}"
fi
