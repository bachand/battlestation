#!/usr/bin/env bash

source '/usr/local/etc/bash_completion.d/git-completion.bash'
source '/usr/local/etc/bash_completion.d/git-prompt.sh'

export GREP_OPTIONS='--color=auto'
export VISUAL=sublime
export EDITOR="$VISUAL"

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM='auto'
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_COMMAND='__git_ps1 "boss:\w" "\\\$ "'

unset HISTFILESIZE
export HISTSIZE=10000
# ignore commands that lead with a space, ignore dups
export HISTCONTROL=ignoreboth,ignoredups

alias ls='ls -alG'
alias sn='sublime'
REPOS="$HOME/repos"
alias cdr="cd $REPOS"

alias rmdd="rm -rf $HOME/Library/Developer/Xcode/DerivedData"

CONFIG_WORK="$HOME/Box/Personal/dotfiles/airbnb"
CONFIG_HOME="$HOME/Dropbox/mbp-retina/dotfiles/home"
if [[ -f "$CONFIG_WORK" ]]; then
  source "$CONFIG_WORK"
elif [[ -f "$CONFIG_HOME" ]]; then
  source "$CONFIG_HOME"
else
  echo "$(tput setaf 1)Can't find a home or work config file$(tput sgr 0)"
fi
