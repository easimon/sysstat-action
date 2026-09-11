#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ -n "${GITHUB_ENV:-}" ]; then
  # Only sar is needed to collect; gnuplot is installed by the post step, which is where it draws.
  # Keeping it out of here means a slow package mirror delays the report instead of the whole build.
  # shellcheck source=install-packages.sh
  . "${SCRIPT_DIR}/install-packages.sh"
  ensure_command sar sysstat || echo "::warning:: could not install sysstat"
fi

# Without sar there is nothing to collect, and writing the SAR_* variables anyway would tell the post
# step that a run exists - it would then fail on a missing data file instead of skipping quietly.
if ! command -v sar > /dev/null 2>&1; then
  echo "::warning:: sar is not available, skipping system statistics for this job."
  exit 0
fi

interval=10
datafile="$(mktemp --tmpdir sardata.XXXXXXXXXX)"
builddir="$(mktemp --directory --tmpdir sysstat-build.XXXXXXXXXX)"

sar -o "$datafile" $interval >/dev/null 2>&1 &

sar_pid=$!

echo "SAR started in background, pid: $sar_pid, data file $datafile"

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "SAR_PID=$sar_pid" >> $GITHUB_ENV
  echo "SAR_DATAFILE=$datafile" >> $GITHUB_ENV
  echo "SAR_BUILDDIR=$builddir" >> $GITHUB_ENV
fi
