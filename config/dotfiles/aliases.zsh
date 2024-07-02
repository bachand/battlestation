#!/bin/zsh

alias g='git'
alias be='bundle exec'
alias ber='bundle exec rake'

alias ytdl='youtube-dl'

alias ls='ls -alG'
alias cdr="cd $HOME/repos"

alias sn='code'
alias v='vim'

# Apple says that anything requiring a developer to delete `DerivedData` is a serious bug in Xcode.
alias rmdd="echo I\'m sorry `id -un`, I\'m afraid I can\'t do that"

# Rebase the current branch over where it branched from master.
# TODO: Change to main.
alias rbi="git rebase -i \$(git merge-base HEAD origin/master)"
