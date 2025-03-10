- Make VS Code the default way to open .txt, .md, etc. files
- Add a git command to delete all local branches not matching a regex. This would be useful for deleting all local branches that don't contain a prefix like `mb-`.
- Figure out a way to not have to run `bundle install` as an admin. Should the first thing that `battlestation` does be install `rbenv`/`rvm`? Or should we specify a path for bundler to install to?
- Add home folder to Finder sidebar
- Add https://youtu.be/St2jUxnCVKI?t=29s
- Set up `locate` database: `sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist`
- Install [San Francisco fonts](https://developer.apple.com/fonts/)
- Set up `xfuncname` to improve `git grep -p`. See [Dave Lee's](https://github.com/kastiglione/dotfiles/blob/e1d171dbfbf378483f35d1eff783f2de1852b04f/gitconfig) as an example.
- Support `main` or `master` as primary branch (see Dan's [solution](https://github.com/dfed/MagCat/commit/0a8e56087f417e2c47c626f5a1fdf66ed5be99f5)).

### Paths to sync
- `$HOME/.ssh`

### Automate installing Launch Daemon
The manual steps (for Michael's setup) are:

1. `cp /Users/michael/repos/battlestation/config/com.battlestation.startup.plist ~/Library/LaunchAgents/`
2. `launchctl load -w ~/Library/LaunchAgents/com.battlestation.startup.plist`

### Z shell

- [`cd_recent()`](https://gitlab.com/GeorgeLyon/rennaizshsance/blob/master/plugins/cd_recent/cd_recent.plugin.zsh)
- [`select_one()`](https://gist.github.com/GeorgeLyon/325c1404ed0139a08dd048fa7f438477)
- Automatically [handle](https://github.com/zsh-users/zsh-completions/issues/433#issuecomment-390600994) insecure directories, which I needed to deal with when I set up on Big Sur.
