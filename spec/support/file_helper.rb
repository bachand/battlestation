# frozen_string_literal: true

# Adapted from https://github.com/bbatsov/rubocop/blob/master/spec/support/file_helper.rb

require 'fileutils'

module FileHelper
  def create_file(file_path, content)
    file_path = File.expand_path file_path

    dir_path = File.dirname file_path
    FileUtils.makedirs dir_path unless File.exist? dir_path

    File.open file_path, 'w' do |file|
      case content
      when String
        file.puts content
      when Array
        file.puts content.join("\n")
      end
    end
  end
end
