#!/usr/bin/env bash

# Installs packages that are not already present.
#
# Runner images ship sysstat, and often gnuplot too, so the common case does no package work at all.
# When something is missing, the install is tried against the existing package lists first and only
# falls back to refreshing them - `apt-get update` talks to every configured repository and is by far
# the slowest part: on one run it took 13m40s while downloading the 38 MB of packages from the same
# host took 9s. Recommends are skipped; for gnuplot-nox alone they pull in imagemagick, ghostscript,
# groff and a font chain that nothing here uses.

# A refresh that has to happen is bounded twice over. On the run above, 5 of 24 fetches stalled and
# accounted for 813 of its 816 seconds, while the median fetch took 0.12s - the mirror was fine, single
# connections were not. Acquire::http::Timeout caps each of those; Acquire::Retries gets the item on a
# second attempt rather than leaving the list incomplete; Acquire::Languages=none skips the
# translation files, which were a quarter of the requests and are of no use here. The outer `timeout`
# is the backstop for whatever those options do not cover: a partial list is fine, since the install
# that follows decides whether it was enough.
APT_UPDATE_TIMEOUT="${APT_UPDATE_TIMEOUT:-120}"

function apt_update {
  # timeout inside sudo, not around it: the other way the signal goes to sudo and apt-get keeps
  # running as root, holding its locks.
  sudo timeout "${APT_UPDATE_TIMEOUT}" apt-get update \
    -o Acquire::http::Timeout=15 \
    -o Acquire::https::Timeout=15 \
    -o Acquire::Retries=3 \
    -o Acquire::Languages=none \
    || echo "::warning:: apt-get update did not finish within ${APT_UPDATE_TIMEOUT}s, continuing anyway"
}

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
  apt_update
  sudo apt-get install -y --no-install-recommends "${missing[@]}"
}
