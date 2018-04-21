# frozen_string_literal: true

module Battlestation

  module Utils

    def self.put_error(message)
      if ! message.empty? && ! message.nil?
        STDERR.puts "#{message}\n"
      end
    end

    def self.exit_on_error(message = "")
      put_error(message)
      exit 1
    end
  end
end
