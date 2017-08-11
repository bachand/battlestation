#!/usr/bin/env bash

pushd $(dirname $0) > /dev/null
readonly SCRIPT_DIR=$(pwd)
popd > /dev/null

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
  # TODO: check that the directory exists
  if [[ ! -f $1 ]] && [[ ! -d $1 ]]; then
    echo "$1 does not exist, creating link to $2"
    ln -s "$2" "$1"
  else
    if [[ ! -h $1 ]]; then
      echo "$(tput setaf 1)$1 exists but is not a link; consider removing existing file and re-running this script$(tput setaf 0)"
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

create_link "$HOME/.bashrc" "$SCRIPT_DIR/bashrc"
create_link "$HOME/.bash_profile" "$SCRIPT_DIR/bash_profile"
create_link "$HOME/.gitconfig" "$SCRIPT_DIR/gitconfig"
create_link "$HOME/.npmrc" "$SCRIPT_DIR/npmrc"
create_link "$HOME/Library/Application Support/Code/User/settings.json" "$SCRIPT_DIR/vscode_settings.json"

chmod 755 "$PWD/git-cleanup"
create_link "/usr/local/bin/git-cleanup" "$PWD/git-cleanup"

SUBLIME_PATH='/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
if [[ -f "$SUBLIME_PATH" ]]; then
  create_link '/usr/local/bin/sublime' "$SUBLIME_PATH"
else
  echo "$(tput setaf 1)Please install Sublime Text and then re-run$(tput sgr 0)"
  exit 1
fi

SUBLIME_SETTINGS_SOURCE_PATH="$SCRIPT_DIR/sublime"
SUBLIME_SETTINGS_TARGET_PATH="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
if [[ -d "$SUBLIME_SETTINGS_TARGET_PATH" ]]; then
  find "$SUBLIME_SETTINGS_SOURCE_PATH" -type f -name *.sublime-settings | while read line; do
    SETTINGS_FILENAME=$(basename $line)

    SOURCE_PATH="$SUBLIME_SETTINGS_SOURCE_PATH/$SETTINGS_FILENAME"
    TARGET_PATH="$SUBLIME_SETTINGS_TARGET_PATH/$SETTINGS_FILENAME"

    create_link "$TARGET_PATH" "$SOURCE_PATH"
  done
else
  echo "$(tput setaf 1)$SUBLIME_SETTINGS_TARGET_PATH doesn't exist; can't install Sublime settings$(tput sgr 0)"
  exit 1
fi
