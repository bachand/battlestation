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
