#!/bin/bash

export PATH="/usr/local/sbin:$PATH" # Homebrew
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH=/Applications/CMake.app/Contents/bin:$PATH # for compiling swift repo

# only source .bashrc if we are interactive
case "$-" in
*i*)
  [[ -r ~/.bashrc ]] && source ~/.bashrc
  ;;
esac

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
