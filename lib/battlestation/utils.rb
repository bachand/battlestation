# frozen_string_literal: true

module Battlestation

  module Utils

    def self.exit_on_error(message = "")
      if ! message.empty? && ! message.nil?
        STDERR.puts "#{message}\n"
      end

      exit 1
    end
  end
end
