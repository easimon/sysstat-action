#!/usr/bin/env bash

# Installs packages that are not already present.
#
# Runner images ship sysstat, and often gnuplot too, so the common case does no package work at all.
# When something is missing, the install is tried against the existing package lists first and only
# falls back to refreshing them - `apt-get update` talks to every configured repository and is by far
# the slowest part: on one run it took 13m40s while downloading the 38 MB of packages from the same
# host took 9s. Recommends are skipped; for gnuplot-nox alone they pull in imagemagick, ghostscript,
# groff and a font chain that nothing here uses.

function install_packages {
  local missing=()
  local package
  for package in "$@"; do
    if ! dpkg-query --show --showformat='${db:Status-Status}' "$package" 2>/dev/null | grep -q '^installed$'; then
      missing+=("$package")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo "Already installed: $*"
    return 0
  fi

  echo "Installing ${missing[*]}"
  if sudo apt-get install -y --no-install-recommends "${missing[@]}"; then
    return 0
  fi

  echo "Install failed, refreshing package lists and retrying"
  sudo apt-get update && sudo apt-get install -y --no-install-recommends "${missing[@]}"
}
