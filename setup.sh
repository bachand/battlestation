#!/usr/bin/env bash

verify_and_install_package () {
  if [[ $# == 1 ]]; then
    if ! brew list "$1" >/dev/null 2>&1; then
      brew install "$1" >/dev/null 2>&1;
    fi
  else
    return 1
  fi
}

function create_link() {
  if [[ ! -f $1 ]] && [[ ! -d $1 ]]; then
    echo "$1 does not exist, creating link to $2"
    ln -s "$2" "$1"
  else
    if [[ ! -h $1 ]]; then
      echo "$1 exists but is not a link; consider removing existing file and re-running this script"
    fi
  fi
}

if type brew >/dev/null 2>&1; then
  if ! brew doctor >/dev/null 2>&1; then
    echo 'Please run `brew doctor` and correct issues before proceeding' 1>&2
    exit 1
  fi

  verify_and_install_package 'bash-completion'
  if [[ $? != 0 ]]; then
    echo 'Error verifying or installing bash-completion package' 1>&2
    exit 1
  fi

  verify_and_install_package 'carthage'
  if [[ $? != 0 ]]; then
    echo 'Error verifying or installing carthage package' 1>&2
    exit 1
  fi
else
  echo 'Please install Homebrew' 1>&2
  exit 1
fi

create_link "$HOME/.gitconfig" "$PWD/gitconfig"
