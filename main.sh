#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case "${1:-}" in
  launch|graph|cleanup)
    echo "Executing $1"
    "${SCRIPT_DIR}/${1}.sh"
  ;;
  *) 
    echo "::error:: must supply valid step parameter."
    exit 1
  ;;
esac
