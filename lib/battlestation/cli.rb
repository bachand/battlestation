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
  end
end
