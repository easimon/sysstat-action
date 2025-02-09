#!/usr/bin/env bash

set -euo pipefail

echo "sar cleanup"

if [ -n "${SAR_PID:-}" ]; then
  (kill $SAR_PID && echo "SAR with PID $SAR_PID terminated") || echo "Could not terminate sar"
fi

if [ -n "${SAR_DATAFILE:-}" ]; then
  (rm -f $SAR_DATAFILE && echo "SAR file $SAR_DATAFILE removed") || echo "Could not delete sar file"
fi
