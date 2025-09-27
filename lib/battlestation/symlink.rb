# frozen_string_literal: true

require 'pathname'
require 'fileutils'

module Battlestation

  # A value type representing a symbolic link with comprehensive management capabilities.
  class Symlink
    attr_reader :source_file, :link_pathname

    def initialize(source_file, link_pathname)
      @source_file = Pathname.new(source_file).expand_path
      @link_pathname = Pathname.new(link_pathname).expand_path
    end

    # Checks if the symlink exists and points to the correct source
    # @return [Boolean] true if symlink exists and points to source_file
    def exists?
      return false unless link_pathname.symlink?
      
      begin
        # readlink returns relative or absolute path, we need to expand it for comparison
        current_target = link_pathname.readlink
        current_target = current_target.expand_path(link_pathname.dirname) unless current_target.absolute?
        current_target == source_file
      rescue => e
        false
      end
    end

    # Checks if the target path exists (file, directory, or symlink)
    # @return [Boolean] true if something exists at the target path
    def target_exists?
      link_pathname.exist? || link_pathname.symlink?
    end

    # Creates the symlink with comprehensive error handling
    # @return [Boolean] true if created successfully, false otherwise
    # @raise [SymlinkError] for various error conditions
    def create!
      validate_source_file!
      validate_target_directory!
      
      begin
        handle_existing_target!
      rescue SymlinkAlreadyCorrect
        # Symlink already exists and is correct
        return true
      end
      
      begin
        link_pathname.make_symlink(source_file)
        true
      rescue => e
        raise SymlinkError, "Failed to create symlink #{link_pathname} -> #{source_file}: #{e.message}"
      end
    end

    # Creates the symlink, returning true/false instead of raising errors
    # @return [Boolean] true if created successfully, false otherwise
    def create
      create!
      true
    rescue SymlinkError
      false
    end

    # Removes the symlink if it exists
    # @return [Boolean] true if removed or didn't exist, false on error
    def remove!
      return true unless target_exists?
      
      unless link_pathname.symlink?
        raise SymlinkError, "Target exists but is not a symlink: #{link_pathname}"
      end
      
      begin
        link_pathname.unlink
        true
      rescue => e
        raise SymlinkError, "Failed to remove symlink #{link_pathname}: #{e.message}"
      end
    end

    # Safe version of remove! that returns boolean instead of raising
    # @return [Boolean] true if removed successfully, false otherwise
    def remove
      remove!
      true
    rescue SymlinkError
      false
    end

    # Gets detailed information about the current state
    # @return [Hash] status information
    def status
      current_target = nil
      if link_pathname.symlink?
        begin
          raw_target = link_pathname.readlink
          current_target = raw_target.absolute? ? raw_target : raw_target.expand_path(link_pathname.dirname)
        rescue => e
          current_target = nil
        end
      end

      {
        source_exists: source_file.exist?,
        target_exists: target_exists?,
        is_symlink: link_pathname.symlink?,
        points_to_source: exists?,
        current_target: current_target&.to_s,
        expected_target: source_file.to_s,
        target_directory_writable: link_pathname.dirname.writable?
      }
    end

    # Returns a human-readable description of the symlink status
    # @return [String] status description
    def describe_status
      s = status
      
      if !s[:source_exists]
        "✗ Source file does not exist: #{source_file}"
      elsif s[:points_to_source]
        "✓ Symlink exists and points to correct source: #{link_pathname} -> #{source_file}"
      elsif s[:is_symlink] && s[:current_target]
        "✗ Symlink exists but points to different source:\n" +
        "  Current: #{link_pathname} -> #{s[:current_target]}\n" +
        "  Expected: #{link_pathname} -> #{source_file}"
      elsif s[:target_exists]
        "✗ Target path exists but is not a symlink: #{link_pathname}"
      elsif !s[:target_directory_writable]
        "✗ No write permission for target directory: #{link_pathname.dirname}"
      else
        "○ Ready to create symlink: #{link_pathname} -> #{source_file}"
      end
    end

    private

    def validate_source_file!
      unless source_file.exist?
        raise SymlinkError, "Source file does not exist: #{source_file}"
      end
    end

    def validate_target_directory!
      target_dir = link_pathname.dirname
      
      unless target_dir.exist?
        raise SymlinkError, "Target directory does not exist: #{target_dir}"
      end
      
      unless target_dir.writable?
        raise SymlinkError, "No write permission for target directory: #{target_dir}\n" +
                           "Try running with sudo or ensuring you have write access"
      end
    end

    def handle_existing_target!
      return unless target_exists?
      
      if link_pathname.symlink?
        begin
          current_target = link_pathname.readlink
          # Expand relative paths for proper comparison
          current_target = current_target.expand_path(link_pathname.dirname) unless current_target.absolute?
          
          if current_target == source_file
            # Already correct, nothing to do - but we need to avoid trying to create it again
            raise SymlinkAlreadyCorrect, "Symlink already exists and is correct"
          else
            raise SymlinkError, "Symlink exists but points to different source:\n" +
                               "  Current: #{link_pathname} -> #{current_target}\n" +
                               "  Expected: #{link_pathname} -> #{source_file}\n" +
                               "Remove the existing symlink first if you want to replace it"
          end
        rescue SymlinkAlreadyCorrect
          # This is expected when symlink is already correct
          raise
        rescue => e
          raise SymlinkError, "Failed to read existing symlink: #{e.message}"
        end
      else
        raise SymlinkError, "Target path exists but is not a symlink: #{link_pathname}"
      end
    end
  end

  # Custom error class for symlink operations
  class SymlinkError < StandardError; end

  # Internal exception for when symlink already exists and is correct
  class SymlinkAlreadyCorrect < StandardError; end
end
