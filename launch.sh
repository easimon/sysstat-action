#!/usr/bin/env bash

set -euo pipefail

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "Installing necessary tools for sar"
  sudo apt-get install -y sysstat libxml2-utils gnuplot
fi

interval=10
datafile="$(mktemp --tmpdir sardata.XXXXXXXXXX)"

sar -o "$datafile" $interval >/dev/null 2>&1 &

sar_pid=$!

echo "SAR started in background, pid: $sar_pid, data file $datafile"

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "SAR_PID=$sar_pid" >> $GITHUB_ENV
  echo "SAR_DATAFILE=$datafile" >> $GITHUB_ENV
fi
