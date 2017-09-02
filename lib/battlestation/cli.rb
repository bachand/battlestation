# frozen_string_literal: true

module Battlestation

  # Responsible of handling all the command line interface logic.
  class CLI

    # @api public
    #
    # Entry point for the application logic. Here we do the command line arguments processing and
    # inspect the target files.
    #
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(args = ARGV)
      puts args

      return 0
    end
  end
end
