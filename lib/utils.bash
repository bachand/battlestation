#!/bin/bash

#######################################
# Checks if an excutable exists (on any shell).
# Credit goes to https://coderwall.com/p/vpvvna/check-if-given-executable-exists-all-shells
#
# Arguments:
#   Executable name
#######################################
exists() {
  if [[ "$#" -ne 1 ]]; then
    >&2 echo "usage: exists <executable_name>"
    return 1
  fi

  type -t "$1" > /dev/null 2>&1
}
