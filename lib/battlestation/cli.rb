# frozen_string_literal: true

require 'pathname'

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

      run_legacy_setup_script(current_dirname)

      install_packages(current_dirname)

      verify_rbenv

      ruby_version_path = File.join current_dirname, '../../.ruby-version'
      ruby_version = (File.read ruby_version_path).strip

      install_ruby_if_necessary(ruby_version)

      set_ruby_version(ruby_version)

      return $?.exitstatus
    end

    private

    def run_legacy_setup_script(current_dirname)
      setup_path = File.join current_dirname, '../../bin/setup'
      system 'bash', '-c', setup_path
    end

    def install_packages(current_dirname)
      # Slowly bringing code into ruby from the monolithic setup script.
      system 'bash', '-c', %{
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

packages=( git ag fzf rbenv )
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

    def install_ruby_if_necessary(version)
      rbenv_versions_string = `rbenv versions`

      unless rbenv_versions_string.include? version
        system 'bash', '-c', %{
rbenv install #{version}
        }
      end
    end

    def set_ruby_version(version)
      system 'bash', '-c', %{
rbenv global #{version}
      }
    end
  end
end
