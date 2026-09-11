#!/usr/bin/env bash

# Installs a package only when the command it provides is missing, and keeps apt from stalling a job.
#
# The check is on the command rather than the package: gnuplot-nox conflicts with gnuplot-x11 and
# gnuplot-qt, so asking apt for it on a machine that already has one of those has it swap the user's
# package out on every run. `command -v gnuplot` is also what graph.sh actually needs.
#
# `apt-get update` is only reached when an install has already failed against the current lists. It is
# the slow part: on one measured run it took 13m40s while downloading the 38 MB of packages from the
# same host took 9s, and 5 of its 25 fetches held 813 of those 816 seconds while the median fetch took
# 0.12s. Acquire::http::Timeout cuts a connection that goes quiet. Retries is set to 1 rather than left
# at apt's default of 3, since a stalled fetch would otherwise be waited out four times over.
# Acquire::Languages=none drops the translation files, roughly a third of the requests and of no use
# here. The outer `timeout` bounds whatever those do not cover - a partial list is acceptable, because
# the install that follows decides whether it was enough.

APT_TIMEOUT="${APT_TIMEOUT:-120}"

function apt_get {
  local rc=0
  sudo DEBIAN_FRONTEND=noninteractive timeout --kill-after=10 "${APT_TIMEOUT}" apt-get "$@" \
    -o Acquire::http::Timeout=15 \
    -o Acquire::Retries=1 \
    -o Acquire::Languages=none || rc=$?

  # 124 is timeout's own exit code. Every other non-zero status is apt's and means something else.
  if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
    echo "::warning:: apt-get $1 did not finish within ${APT_TIMEOUT}s"
  fi
  return "$rc"
}

# ensure_command <command> <package>... - installs the packages if the command is not already there.
function ensure_command {
  local command_name="$1"
  shift

  if command -v "$command_name" > /dev/null 2>&1; then
    echo "$command_name is already available"
    return 0
  fi

  echo "Installing $* to provide $command_name"
  if apt_get install -y --no-install-recommends "$@"; then
    return 0
  fi

  echo "Install failed, refreshing package lists and retrying"
  apt_get update || true
  apt_get install -y --no-install-recommends "$@"
}
