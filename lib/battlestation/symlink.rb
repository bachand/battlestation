# frozen_string_literal: true

module Battlestation

  # A value type representing a symbolic link.
  class Symlink

    def initialize(source_file, link_pathname)
      @source_file = source_file
      @link_pathname = link_pathname
    end

    def exists?
      raise NotImplementedError, "todo..."
    end
  end
end
