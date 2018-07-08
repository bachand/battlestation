# frozen_string_literal: true

require_relative '../output'

module Battlestation

  module Utils

    def self.exit_on_error(message = "")
      if ! message.empty? && ! message.nil?
        Output.put_error(message)
      end
      exit 1
    end
  end
end
