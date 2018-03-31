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
      current_pathname = Pathname.new(__FILE__)
      setup_path = File.join current_pathname.dirname, '../../bin/setup'

      system 'bash', '-c', setup_path

      return $?.exitstatus
    end
  end
end
