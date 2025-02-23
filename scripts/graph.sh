#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -z "${SAR_DATAFILE:-}" ]; then
  echo "::error:: SAR_DATAFILE unset."
fi
if [ -z "${SAR_BUILDDIR:-}" ]; then
  echo "::error:: SAR_BUILDDIR unset."
fi

datafile="$SAR_DATAFILE"
workdir="$SAR_BUILDDIR"
reportfile="${workdir}/index.html"

mkdir -p "$workdir/images"

function img_gnuplot_file {
  gpfile="$1"
  shift

  sadf -d "$datafile" -O skipempty -- "$@" -z > .sar.csv
  filename="images/${gpfile}-$(uuidgen).svg"
#  content="$(gnuplot -c "${SCRIPT_DIR}/../gnuplot-scripts/${gpfile}.gnu")" # no xml compaction
  content="$(gnuplot -c "${SCRIPT_DIR}/../gnuplot-scripts/${gpfile}.gnu" | xmllint --noblanks -)" # with xml compaction

  echo "$content" > "${workdir}/${filename}"

  rm -f ".sar.csv"
  echo "${filename}"
}

function sadf_iter {
  col="$1"
  shift

  sadf -d "$datafile" -O skipempty -- "$@" -z | tail -n +2 | cut -d ';' -f $col | sort | uniq
}

function reptruncate {
  echo -n "" > "$reportfile"
}

function rep {
  echo "$@" >> "$reportfile"
}

function img {
  file="$(img_gnuplot_file "$@")"
  rep "<img src=\"$file\" />"
}

function header {
  header="$1"
  rep "<h2>$header</h2>"
  rep
}

function header3 {
  header="$1"
  rep "<h3>$header</h3>"
  rep
}

function sectionbody {
  img "$@"
}

function section {
  header="$1"
  shift
  header "$header"
  sectionbody "$@"
}

function reporthead {
  reptruncate
  rep "<html>"
  rep "<head>"
  rep "<title>System report</title>"
  rep "<link href=\"https://fonts.googleapis.com/css2?family=News+Cycle:wght@400;700&display=swap\" rel=\"stylesheet\">"
  rep "<style>"
  rep "body {
    font-family: 'News Cycle', serif;
    font-size: 14px;
    color: #2f2f2f;
    background-color: #f9f7f1;
  }"
  rep "</style>"
  rep "</head>"
  rep "<body>"
  rep "<h1>System report</h1>"
}

function reportfoot {
  rep "</body>"
  rep "</html>"
}

## begin report output

reporthead

section "CPU" cpu -u ALL -P all
section "System Load" load -q LOAD
section "Memory Consumption" memory -r

header "Network"
sectionbody net-ip4 -n IP
#sectionbody net-ip6 -n IP6

for dev in $(sadf_iter 4 -n DEV); do
  header3 "Network bytes $dev"
  sectionbody net-dev -n DEV --iface="$dev"
done 

header "Disk utilization"
# TODO: section "Disk" -d
#header3 "Disk usage $disk"
sectionbody block-bytes -b
sectionbody block-tps -b

header "Filesystem usage"
for disk in $(sadf_iter 4 -F); do
  header3 "Disk usage $disk"
  sectionbody filesystem -F --fs="$disk"
done 

reportfoot

#if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
#  cat "$reportfile" >> $GITHUB_STEP_SUMMARY
#fi
