#!/bin/bash

#######################################
# Opens a link in the iOS simulator.
#
# Arguments:
#   Link string, e.g. "https://www.airbnb.com/rooms/23001080"
#######################################
odl() {
  xcrun simctl openurl booted $1
}

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

#######################################
# Creates a .tar.gz file in the same directory. Hidden files and directories (i.e. those prefixed
# with '.') are excluded.
#
# Arguments:
#   File or directory path
#######################################
pack() {
  if [[ "$#" -ne 1 ]]; then
    >&2 echo "usage: pack <path>"
    return 1
  fi

  if [[ "$1" == '.' ]]; then
    # Passing '.' to `tar` will create an empty archive due to how `--exclude=".*"` works. There
    # does not seem to be a trivial way to canonicalize paths on macOS. This simple limitation
    # (with an easy workaround) avoids a fair amount of added complexity.
    >&2 echo "Please specify a canonical path instead '.'"
    return 2
  fi

  input_basename=$(basename "$1")

  output_dirname=$(dirname "$1")
  output_basename="$input_basename.tar.gz"

  output_path="$output_dirname/$output_basename"

  if [[ -f "$output_path" ]]; then
    >&2 echo "$output_path already exists!"
    return 3
  fi

  tar --exclude=".*" -cvzf "$output_path" -C "$output_dirname" "$input_basename"
}

#######################################
# Delete pattern. This function will delete the lines in the specified file that match the specified
# pattern.
#
# Arguments:
#   Pattern
#   File path
#######################################
dp() {
  if [[ "$#" -ne 2 ]]; then
    echo "usage: dp <pattern> <file_path>"
    return 1
  fi

  local pattern="$1"
  local file_path="$2"

  sed -i '' "/$pattern/d" "$file_path"
}
