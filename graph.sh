#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -z "${SAR_DATAFILE:-}" ]; then
  echo "::error:: SAR_DATAFILE unset."
fi

datafile="$SAR_DATAFILE"
workdir="./build/sar-report"
reportfile="${workdir}/REPORT.md"

mkdir -p "$workdir"
rm -f "$workdir/"*

function img_gnuplot_file {
  gpfile="$1"
  shift

  sadf -d "$datafile" -O skipempty -- "$@" -z > .sar.csv
  filename="${gpfile}-$(uuidgen).svg"
  content="$(gnuplot -c "${SCRIPT_DIR}/gnuplot-scripts/${gpfile}.gnu" | xmllint --noblanks --pretty 0 --nsclean -)"

  echo "$content" > "${workdir}/${filename}"

  rm -f ".sar.csv"
  echo "${filename}"
}

function img_gnuplot {
  gpfile="$1"
  shift

  sadf -d "$datafile" -O skipempty -- "$@" -z > .sar.csv
  content="$(gnuplot -c "${SCRIPT_DIR}/gnuplot-scripts/${gpfile}.gnu" | xmllint --noblanks --pretty 0 --nsclean -)"

  rm -f ".sar.csv"
  echo "$content"
}

function sadf_iter {
  col="$1"
  shift

  sadf -d "$datafile" -O skipempty -- "$@" -z | tail -n +2 | cut -d ';' -f $col | sort | uniq
}

function rep {
  echo "$@" >> "$reportfile"
}

function img {
  filecontent="$(img_gnuplot "$@")"
  rep "$filecontent"
}

function header {
  header="$1"
  rep "## $header"
  rep
}

function sectionbody {
  img "$@"
  rep
}

function section {
  header="$1"
  shift
  header "$header"
  sectionbody "$@"
}

echo "# Sysstat report " > "$reportfile"
rep 

section "CPU" cpu -u ALL -P all
section "System Load" load -q LOAD
section "Memory Consumption" memory -r

header "Network"
sectionbody net-ip4 -n IP
sectionbody net-ip6 -n IP6
# todo: section "Disk" -d

header "Filesystem usage"
for disk in $(sadf_iter 4 -F); do
  sectionbody filesystem -F --fs="$disk"
done 

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat "$reportfile" >> $GITHUB_STEP_SUMMARY

  echo "# data"
  echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
  sadf -d "$datafile" -O skipempty -- -z >> $GITHUB_STEP_SUMMARY
  echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
fi
