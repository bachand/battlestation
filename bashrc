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
REPOS="$HOME/repos"
alias cdr="cd $REPOS"

CONFIG_WORK="$HOME/Box/Personal/dotfiles/airbnb"
CONFIG_HOME="$HOME/Dropbox/mbp-retina/dotfiles/home"
if [[ -f "$CONFIG_WORK" ]]; then
  source "$CONFIG_WORK"
elif [[ -f "$CONFIG_HOME" ]]; then
  source "$CONFIG_HOME"
else
  echo "$(tput setaf 1)Can't find a home or work config file$(tput sgr 0)"
fi

start_ssh_agent() {
  ssh-add -l &>/dev/null
  if [[ $? == 2 ]]; then
    test -r ~/.ssh-agent && eval "$(<~/.ssh-agent)" >/dev/null

    ssh-add -l &>/dev/null
    if [[ $? == 2 ]]; then
      (umask 066; ssh-agent > ~/.ssh-agent)
      eval "$(<~/.ssh-agent)" >/dev/null
      ssh-add
    fi
  fi
}

start_ssh_agent
