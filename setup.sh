#!/bin/bash

pushd $(dirname $0) > /dev/null
readonly SCRIPT_DIR=$(pwd)
popd > /dev/null

#######################################
# Prints the provided message to STDOUT in the default color.
#
# Arguments:
#   Verbose message
# Returns:
#######################################
echo_verbose() {
  printf "%s\n" "$*" >&2;
}

#######################################
# Prints the provided message to STDOUT in green.
#
# Arguments:
#   Info message
# Returns:
#######################################
echo_info() {
  printf "$(tput setaf 2)%s$(tput sgr 0)\n" "$*" >&2;
}

#######################################
# Prints the provided message to STDERR in red.
#
# Arguments:
#   Error message
# Returns:
#######################################
echo_error() {
  printf "$(tput setaf 1)%s$(tput sgr 0)\n" "$*" >&2;
}

#######################################
# Exits with an error code of 1 if Homebrew is not installed.
#
# Arguments:
# Returns:
#######################################
verify_homebrew() {
  if ! type brew >/dev/null 2>&1; then
    echo_error 'Please install Homebrew'
    exit 1
  fi
}

#######################################
# Installs the specified Homebrew package, if necessary.
#
# Arguments:
#   Name of package
# Returns:
#######################################
install_package() {
  if ! brew list "$1" >/dev/null 2>&1; then
    echo_info "Installing $1 via Homebrew"
    brew install "$1"
  fi
}

#######################################
# Creates a symlink if it doesn't already exist. If a file already exists at the target path, prints
# an error and does nothing.
#
# Arguments:
#   Target Path
#   Source Path
# Returns:
#######################################
create_link() {
  local target_path="$1"
  local source_path="$2"

  if [[ ! -f "$target_path" ]] && [[ -f "$source_path" ]]; then
    # If the target doesn't exist and the source does, make the link!
    ln -s "$2" "$1"
  elif [[ -f "$target_path" ]]; then
    if link_source_path=$(readlink "$target_path"); then
      if [[ "$link_source_path" != "$source_path" ]]; then
        echo_error "$target_path exists but is not a link to $source_path"
      fi
    else
      echo_error "$target_path is not a link"
    fi
  elif [[ ! -f $2 ]]; then
    echo_error "$source_path does not exist"
  fi
}

#######################################
# Symlinks `/usr/local/bin/sublime` to the Sublime binary and installs the Sublime settings. Exits
# with an error code of 1 if this cannot be achieved.
#
# Arguments:
# Returns:
#######################################
setup_sublime() {
  local sublime_path='/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
  local settings_source_path="$SCRIPT_DIR/sublime"
  local settings_target_path="$HOME/Library/Application Support/Sublime Text 3/Packages/User"

  if [[ -f "$sublime_path" ]]; then
    create_link '/usr/local/bin/sublime' "$sublime_path"
  else
    echo_error 'Please install Sublime Text'
    exit 1
  fi

  if [[ -d "$settings_target_path" ]]; then
    find "$settings_source_path" -type f -name *.sublime-settings | while read line; do
      local settings_filename=$(basename $line)

      local source_path="$settings_source_path/$settings_filename"
      local target_path="$settings_target_path/$settings_filename"

      create_link "$target_path" "$source_path"
    done
  else
    echo_error 'Cannot install Sublime settings'
    exit 1
  fi
}

#######################################
# Runs the fzf install script in order to install key bindings and shell completion. Exits with an
# error code of 1 if that script fails.
#
# Arguments:
# Returns:
#######################################
setup_fzf() {
  /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc >/dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    echo_error 'Failed to install fzf'
    exit 1
  fi
}

install_gpmdp() {
  # TODO: install https://github.com/MarshallOfSound/Google-Play-Music-Desktop-Player-UNOFFICIAL-
}


# TODO(MB): Things we would have to do if we wanted this be able to be run from a fresh machine:
#   sudo gem install bundle

verify_homebrew

install_gpmdp 

install_package 'git'

install_package 'fzf'
setup_fzf

create_link "$HOME/.bashrc" "$SCRIPT_DIR/dotfiles/bashrc"
create_link "$HOME/.bash_profile" "$SCRIPT_DIR/dotfiles/bash_profile"
create_link "$HOME/.gitconfig" "$SCRIPT_DIR/dotfiles/gitconfig"
create_link "$HOME/.npmrc" "$SCRIPT_DIR/dotfiles/npmrc"
create_link "$HOME/Library/Application Support/Code/User/settings.json" "$SCRIPT_DIR/vscode_settings.json"

chmod 755 "$PWD/git-cleanup"
create_link "/usr/local/bin/git-cleanup" "$PWD/git-cleanup"

setup_sublime
