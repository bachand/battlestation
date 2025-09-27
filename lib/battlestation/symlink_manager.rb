# frozen_string_literal: true

require_relative 'symlink'
require_relative '../output'

module Battlestation
  # Manages multiple symlinks for the battlestation setup
  class SymlinkManager
    def initialize(verbose: true)
      @verbose = verbose
      @symlinks_to_create = []
    end

    # Add a symlink to be managed
    # @param source_path [String, Pathname] Path to the source file
    # @param target_path [String, Pathname] Path where the symlink should be created
    def add_symlink(source_path, target_path)
      @symlinks_to_create << { source: source_path, target: target_path }
    end

    # Create all registered symlinks
    # @return [Boolean] true if all symlinks were created successfully
    def create_all
      success_count = 0
      errors = []

      @symlinks_to_create.each do |link_info|
        symlink = Symlink.new(link_info[:source], link_info[:target])
        
        if @verbose
          puts "Creating symlink: #{link_info[:target]} -> #{link_info[:source]}"
        end

        begin
          if symlink.create!
            success_count += 1
            if @verbose
              Output.put_success("✓ #{symlink.describe_status}")
            end
          end
        rescue SymlinkError => e
          errors << { symlink: link_info, error: e.message }
          if @verbose
            Output.put_error("✗ #{e.message}")
          end
        end
      end

      if errors.empty?
        if @verbose
          Output.put_success("All #{success_count} symlinks created successfully")
        end
        true
      else
        if @verbose
          Output.put_error("Failed to create #{errors.length} symlinks:")
          errors.each do |error_info|
            Output.put_error("  #{error_info[:symlink][:target]} -> #{error_info[:symlink][:source]}")
            Output.put_error("    #{error_info[:error]}")
          end
        end
        false
      end
    end

    # Check status of all registered symlinks
    # @return [Array<Hash>] status information for all symlinks
    def check_all
      @symlinks_to_create.map do |link_info|
        symlink = Symlink.new(link_info[:source], link_info[:target])
        {
          source: link_info[:source],
          target: link_info[:target],
          status: symlink.status,
          description: symlink.describe_status
        }
      end
    end

    # Remove all registered symlinks (useful for cleanup/uninstall)
    # @return [Boolean] true if all symlinks were removed successfully
    def remove_all
      success_count = 0
      errors = []

      @symlinks_to_create.each do |link_info|
        symlink = Symlink.new(link_info[:source], link_info[:target])
        
        begin
          if symlink.remove!
            success_count += 1
            if @verbose
              Output.put_success("Removed symlink: #{link_info[:target]}")
            end
          end
        rescue SymlinkError => e
          errors << { symlink: link_info, error: e.message }
          if @verbose
            Output.put_error("Failed to remove #{link_info[:target]}: #{e.message}")
          end
        end
      end

      errors.empty?
    end

    # Show detailed status for all symlinks
    def show_status
      statuses = check_all
      
      if statuses.empty?
        Output.put_info("No symlinks configured")
        return
      end

      Output.put_info("Symlink Status Report:")
      statuses.each do |status_info|
        puts "  #{status_info[:description]}"
      end

      working_count = statuses.count { |s| s[:status][:points_to_source] }
      total_count = statuses.length
      
      if working_count == total_count
        Output.put_success("All #{total_count} symlinks are working correctly")
      else
        Output.put_error("#{working_count}/#{total_count} symlinks are working correctly")
      end
    end
  end
end