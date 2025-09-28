# frozen_string_literal: true

require 'pathname'
require 'tmpdir'

require_relative '../output'
require_relative 'symlink_manager'
require 'colorize'

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

      setup_symlinks(current_dirname)

      run_legacy_setup_script(current_dirname)

      install_python()

      install_aws_cli()

      update_homebrew()

      install_packages()

      configure_fzf()

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
      theme='Balthazar 2001'
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

    def setup_symlinks(current_dirname)
      repo_dir = File.expand_path('../../', current_dirname)
      symlinks_config = File.join(repo_dir, 'config/symlinks.yaml')
      
      Output.put_info("Setting up symlinks from configuration...")
      
      manager = SymlinkManager.new(verbose: true)
      
      begin
        # Load symlinks from YAML configuration
        manager.load_from_yaml(symlinks_config, repo_root: repo_dir)
        
        # Ensure executable permissions on scripts
        manager.ensure_executable_permissions
        
        # Create all symlinks
        success = manager.create_all
        
        if success
          Output.put_success("All symlinks created successfully")
        else
          Output.put_error("Some symlinks failed to create - check the output above for details")
          Output.put_info("You may need to run with sudo for system directory symlinks like /usr/local/bin/")
        end
      rescue SymlinkError => e
        Output.put_error("Failed to setup symlinks: #{e.message}")
      end
    end

    def run_legacy_setup_script(current_dirname)
      # The legacy setup script must be executed from a working directory within the repo to support
      # using Git to determine the root directory of the repository.
      Dir.chdir(current_dirname) { system 'bash', '-c', '../../bin/setup' }
    end

    def update_homebrew
      system 'bash', '-c', %{
#{full_homebrew_path} update
      }
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

    def install_packages()
      packages = [
        'cloc',
        'exiftool',
        'ffmpeg',
        'fzf',
        'git',
        'gpg',
        'handbrake',
        'imagemagick',
        'ios-sim',
        'python',
        'rbenv',
        'gh',
      ]

      for package in packages
        if system(full_homebrew_path, 'list', package, out: File::NULL, err: File::NULL)
          # Package is installed. Only update it if it's outdated.
          outdated = system(full_homebrew_path, 'outdated', package, out: File::NULL, err: File::NULL)
          if !outdated
            puts "Upgrading #{package} via Homebrew".colorize(:green)
            system(full_homebrew_path, 'upgrade', package)
          else
            puts "#{package} is up to date.".colorize(:light_black)
          end
        else
          puts "Installing #{package} via Homebrew".colorize(:green)
          system(full_homebrew_path, 'install', package)
        end
      end
    end

    # Runs the fzf install script in order to install key bindings and shell completion.
    def configure_fzf
      system 'bash', '-c', %{
#{homebrew_prefix}/opt/fzf/install --key-bindings --completion --no-update-rc >/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
  echo 'Failed to install fzf'
  exit 1
fi
      }
    end

    # Installs Ruby if necessary.
    def install_ruby(version)
      rbenv_versions_string = `#{homebrew_prefix}/bin/rbenv versions`

      unless rbenv_versions_string.include? version
        system 'bash', '-c', %{
# We need Homebrew in the PATH since `rbenv install` needs to access `ruby-build`.
eval "$(#{full_homebrew_path} shellenv)"
eval "$(#{homebrew_prefix}/bin/rbenv init -)"

# Remove CFLAGS when openssl is fixed. See https://github.com/openssl/openssl/issues/18733#issuecomment-1181810055
CFLAGS="-Wno-error=implicit-function-declaration" #{homebrew_prefix}/bin/rbenv install #{version}
        }
      end
    end

    def set_ruby_version(version)
      system 'bash', '-c', %{
eval "$(#{homebrew_prefix}/bin/rbenv init -)"

#{homebrew_prefix}/bin/rbenv global #{version}
      }
    end

    def install_gems(current_dirname)
      system 'bash', '-c', %{
eval "$(#{homebrew_prefix}/bin/rbenv init -)"

# We install the same version with which we created the Gemfile.lock.
gem install bundler -v 2.1.4
cd "#{current_dirname}/../../"
bundle install
      }
    end

    # As part of this setup we install Homebrew and set up our dotfiles. Accordingly, a naked `brew`
    # command may not yet work. We can use the prefix to create a fully qualified path to the
    # Homebrew binary.
    # @returns [String] the prefix for the Homebrew installation directory.
    # @raises [RuntimeError] if Homebrew is not installed.
    def homebrew_prefix
      apple_silicon_prefix = '/opt/homebrew'
      intel_prefix = '/usr/local'
      binary_suffix = 'bin/brew'
      if File.exist? File.join(apple_silicon_prefix, binary_suffix)
        return apple_silicon_prefix
      elsif File.exist? File.join(intel_prefix, binary_suffix)
        return intel_prefix
      else
        raise 'Homebrew is not installed'
      end
    end

    # @returns [String] the fully qualified path to the Homebrew binary.
    # @raises [RuntimeError] if Homebrew is not installed.
    def full_homebrew_path
      File.join(homebrew_prefix, 'bin/brew')
    end
  end
end
