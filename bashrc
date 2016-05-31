#!/usr/bin/env bash

for f in /usr/local/etc/bash_completion.d/*; do
  source $f
done

export GREP_OPTIONS='--color=auto'
export VISUAL=sublime
export EDITOR="$VISUAL"

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM='auto'
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_COMMAND='__git_ps1 "boss:\w" "\\\$ "'

unset HISTFILESIZE
export HISTSIZE=10000
# ignore commands that lead with a space, ignore dups
export HISTCONTROL=ignoreboth,ignoredups

alias ls='ls -alG'
alias sn='sublime'

AIRBNB_CONFIG="$HOME/Box/Personal/dotfiles/airbnb"
if [[ -f "$AIRBNB_CONFIG" ]]; then
  source "$AIRBNB_CONFIG"
else
  echo "$(tput setaf 1)Unable to find Airbnb config file$(tput sgr 0)"
fi
