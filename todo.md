- Integrate with Travis
- Make Sublime text the default way to open .txt, .md, etc. files
- Add a git command to delete all local branches not matching a regex. This would be useful for deleting all local branches that don't contain my prefix, `mb-`.
- Figure out a way to not have to run `bundle install` as an admin. Should the first thing that `battlestation` does be install `rbenv`/`rvm`? Or should we specify a path for bundler to install to?
- Add home folder to Finder sidebar
- Add https://youtu.be/St2jUxnCVKI?t=29s
- Set up `locate` database: `sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist`

### Paths to sync
- `$HOME/.ssh`

### Automate installing Launch Daemon
The manual steps are:

1. `sudo cp /path/to/com.battlestation.startup.plist /Library/LaunchDaemons/`
2. `sudo launchctl load -w /Library/LaunchDaemons/com.battlestation.startup.plist`
