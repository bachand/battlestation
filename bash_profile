#!/usr/bin/env bash

export PATH="/usr/local/sbin:$PATH" # Homebrew
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# for GoldKey
export SSH_AUTH_SOCK=$TMPDIR/ssh-agent-$USER.sock

# only source .bashrc if we are interactive
case "$-" in
*i*)
  if [[ -r ~/.bashrc ]]; then source ~/.bashrc; fi
  ;;
esac

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
