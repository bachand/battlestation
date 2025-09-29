# frozen_string_literal: true

require 'yaml'
require 'pathname'
require 'fileutils'
require_relative '../output'

module Battlestation
  # Simple symlink management with YAML configuration support
  class SymlinkManager
    def initialize(config_path, repo_root: nil, home_dir: ENV['HOME'], verbose: true)
      @config_path = Pathname.new(config_path)
      @repo_root = repo_root ? Pathname.new(repo_root) : @config_path.dirname.parent
      @home_dir = Pathname.new(home_dir)
      @verbose = verbose
      @symlinks = load_config
    end

    def create_all
      results = @symlinks.map { |link| create_symlink(link) }
      success_count = results.count(true)
      
      if @verbose
        if success_count == @symlinks.length
          Output.put_success("All #{success_count} symlinks created successfully")
        else
          Output.put_error("#{success_count}/#{@symlinks.length} symlinks created successfully")
        end
      end
      
      success_count == @symlinks.length
    end

    def status
      @symlinks.each do |link|
        source = resolve_path(link['source_path'], @repo_root)
        target = resolve_path(link['target_path'], @home_dir)
        
        if target.symlink?
          current_source = target.readlink
          current_source = current_source.expand_path(target.dirname) unless current_source.absolute?
          
          if current_source == source
            puts "✓ #{target} -> #{source}"
          else
            puts "✗ #{target} -> #{current_source} (expected: #{source})"
          end
        elsif target.exist?
          puts "✗ #{target} exists but is not a symlink"
        elsif !source.exist?
          puts "✗ Source missing: #{source}"
        else
          puts "○ Ready to create: #{target} -> #{source}"
        end
      end
    end

    def remove_all
      @symlinks.each do |link|
        target = resolve_path(link['target_path'], @home_dir)
        if target.symlink?
          target.unlink
          puts "Removed: #{target}" if @verbose
        end
      end
    end

    private

    def load_config
      unless @config_path.exist?
        raise "Configuration file not found: #{@config_path}"
      end

      config = YAML.load_file(@config_path)
      unless config.is_a?(Array)
        raise "Configuration must be an array of symlink definitions"
      end

      config.each do |link|
        unless link['source_path'] && link['target_path']
          raise "Each symlink must have 'source_path' and 'target_path'"
        end
      end

      if @verbose
        Output.put_info("Loaded #{config.length} symlink definitions")
      end

      config
    end

    def resolve_path(path_str, base_dir)
      path = Pathname.new(path_str)
      path.absolute? ? path : base_dir.join(path)
    end

    def create_symlink(link)
      source = resolve_path(link['source_path'], @repo_root)
      target = resolve_path(link['target_path'], @home_dir)

      # Ensure source exists
      unless source.exist?
        puts "✗ Source missing: #{source}" if @verbose
        return false
      end

      # Ensure target directory exists and is writable
      target_dir = target.dirname
      unless target_dir.exist?
        puts "✗ Target directory missing: #{target_dir}" if @verbose
        return false
      end

      unless target_dir.writable?
        puts "✗ No write permission: #{target_dir}" if @verbose
        return false
      end

      # Set executable permission for bin files before creating symlink
      source.chmod(0755) if source.to_s.match?(/bin\/[^\/]+$/)

      # Handle existing target
      if target.exist? || target.symlink?
        if target.symlink?
          current_source = target.readlink
          current_source = current_source.expand_path(target.dirname) unless current_source.absolute?
          
          if current_source == source
            puts "✓ Already correct: #{target} -> #{source}" if @verbose
            return true
          else
            puts "✗ Points elsewhere: #{target} -> #{current_source}" if @verbose
            return false
          end
        else
          puts "✗ File exists: #{target}" if @verbose
          return false
        end
      end

      # Create symlink
      target.make_symlink(source)
      puts "✓ Created: #{target} -> #{source}" if @verbose
      true
    rescue => e
      puts "✗ Failed to create #{target}: #{e.message}" if @verbose
      false
    end
  end
end