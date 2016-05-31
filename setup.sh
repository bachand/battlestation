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
  verify_and_install_package 'git'
  if [[ $? != 0 ]]; then
    echo 'Error verifying or installing git package' 1>&2
    exit 1
  fi
else
  echo 'Please install Homebrew' 1>&2
  exit 1
fi

create_link "$HOME/.bashrc" "$PWD/bashrc"
create_link "$HOME/.bash_profile" "$PWD/bash_profile"
create_link "$HOME/.gitconfig" "$PWD/gitconfig"

chmod 755 "$PWD/git-cleanup"
create_link "/usr/local/bin/git-cleanup" "$PWD/git-cleanup"

SUBLIME_PATH='/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
if [[ -f "$SUBLIME_PATH" ]]; then
  create_link '/usr/local/bin/sublime' "$SUBLIME_PATH"
else
  echo "$(tput setaf 1)Please install Sublime Text and then re-run$(tput sgr 0)"
fi
