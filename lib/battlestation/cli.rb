# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

require_relative '../output'

module Battlestation

  # Responsible of handling all the command line interface logic.
  class CLI

    # Entry point for the application logic. Here we do the command line arguments processing and
    # inspect the target files.
    #
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(args = ARGV)
      current_dirname = Pathname.new(__FILE__).dirname

      install_terminal_theme(current_dirname)

      configure_xcode()

      run_legacy_setup_script(current_dirname)

      install_python()

      install_aws_cli()

      install_packages(current_dirname)

      verify_rbenv

      ruby_version_path = File.join current_dirname, '../../.ruby-version'
      ruby_version = (File.read ruby_version_path).strip

      install_ruby(ruby_version)

      set_ruby_version(ruby_version)

      install_gems(current_dirname)

      Output.put_success("Setup completed.")
      Output.put_info("Please close and reopen your shell.")

      return $?.exitstatus
    end

    private

    # Installs my Terminal theme and sets it as the default.
    # @param current_dirname [String] The absolute path to the directory where this script will
    # execute.
    def install_terminal_theme(current_dirname)
      plist_buddy='/usr/libexec/PlistBuddy'
      terminal_preferences='$HOME/Library/Preferences/com.apple.Terminal.plist'
      theme='Balthazar 2000'
      theme_file = File.join(current_dirname, '../../config/terminal_theme.terminal')

      system 'bash', '-c', %{
#{plist_buddy} -c "Print :'Window Settings':'#{theme}'" #{terminal_preferences} >/dev/null 2>&1
theme_search_result=$?
if [[ $theme_search_result -ne 0 ]]; then
  echo "Adding theme to Terminal: #{theme}"
  # Create a new entry in the dictionary of profiles
  #{plist_buddy} -c "Add :'Window Settings':'#{theme}' dict {}" #{terminal_preferences}
  # Merge in the settings
  #{plist_buddy} -c "Merge #{theme_file} :'Window Settings':'#{theme}'" #{terminal_preferences}

  echo "Setting theme as default: #{theme}"
  #{plist_buddy} -c "Set :'Default Window Settings' '#{theme}'" #{terminal_preferences}
  #{plist_buddy} -c "Set :'Startup Window Settings' '#{theme}'" #{terminal_preferences}
fi
}
    end

    def configure_xcode
      system 'bash', '-c', %{
defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool YES
defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool YES
defaults write com.apple.dt.Xcode DVTTextIndentTabWidth -int 2
defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 2
defaults write com.apple.dt.Xcode DVTTextPageGuideLocation -int 100
}
    end

    def run_legacy_setup_script(current_dirname)
      setup_path = File.join current_dirname, '../../bin/setup'
      system 'bash', '-c', setup_path
    end

    def install_python
      # Find a way to automate installing python itself
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          system 'bash', '-c', %{
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
}
        end
      end
    end

    def install_aws_cli
      system 'bash', '-c', %{
if ! pip show awscli >/dev/null; then
  pip install awscli --upgrade --user
fi
}
    end

    def install_packages(current_dirname)
      packages = [
        'ag',
        'cloc',
        'exiftool',
        'fzf',
        'git',
        'gpg',
        'handbrake',
        'imagemagick',
        'ios-sim',
        'python',
        'rbenv',
        'terminal-notifier',
        'watchman', # Can be used to speed up Git via core.fsmonitor.
        'youtube-dl',
      ]
      # Slowly bringing code into ruby from the monolithic setup script.
      system 'bash', '-c', %{
#######################################
# Prints the provided message to STDOUT in green.
#
# Arguments:
#   Info message
#######################################
echo_info() {
  printf "$(tput setaf 2)%s$(tput sgr 0)\n" "$*" >&2;
}

#######################################
# Installs the specified Homebrew package if it isn't installed. If it is, tries to upgrade the
# package.
#
# Arguments:
#   Name of package
#######################################
install_or_upgrade_package() {
  if ! brew list "$1" >/dev/null 2>&1; then
    echo_info "Installing $1 via Homebrew"
    brew install "$1"
  else
    # TODO: find a way to only update if needed to prevent errors in console.
    brew upgrade "$1"
  fi
}

packages=( #{packages.join(" ")} )
for package in "${packages[@]}"
do
  install_or_upgrade_package "$package"
done
      }
    end

    def verify_rbenv
      system 'bash', '-c', %{
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
      }
    end

    # Installs Ruby if necessary.
    def install_ruby(version)
      rbenv_versions_string = `rbenv versions`

      unless rbenv_versions_string.include? version
        system 'bash', '-c', %{
rbenv init
eval "$(rbenv init -)"

rbenv install #{version}
        }
      end
    end

    def set_ruby_version(version)
      system 'bash', '-c', %{
rbenv init
eval "$(rbenv init -)"

rbenv global #{version}
rbenv shell #{version}
      }
    end

    def install_gems(current_dirname)
      system 'bash', '-c', %{
rbenv init
eval "$(rbenv init -)"

gem install bundler
cd "#{current_dirname}/../../"
bundle install
      }
    end
  end
end
