# frozen_string_literal: true

require 'pathname'
require 'fileutils'

module Battlestation
  # Synchronizes symlinks for battlestation setup
  class SymlinkSync
    # Symlink definitions - source paths relative to repo root, target paths relative to home
    SYMLINKS = [
      { target_path: '.zshenv', source_path: 'config/dotfiles/zshenv' },
      { target_path: '.zshrc', source_path: 'config/dotfiles/zshrc' },
      { target_path: '.gitconfig', source_path: 'config/dotfiles/gitconfig' },
      { target_path: '.npmrc', source_path: 'config/dotfiles/npmrc' },
      { target_path: 'Library/Application Support/Code/User/settings.json', source_path: 'config/vscode_settings.json' },
      { target_path: 'Library/Developer/Xcode/Templates/File Templates/User Templates/Empty Swift File.xctemplate', source_path: 'xcode/Empty Swift File.xctemplate' },
      { target_path: '/usr/local/bin/git-cleanup', source_path: 'bin/git-cleanup' }
    ].freeze

    def initialize(repo_root:, home_dir: ENV['HOME'])
      @repo_root = Pathname.new(repo_root)
      @home_dir = Pathname.new(home_dir)
    end

    def sync
      SYMLINKS.map { |link| sync_symlink(link) }
    end

    private

    def resolve_path(path_str, base_dir)
      path = Pathname.new(path_str)
      path.absolute? ? path : base_dir.join(path)
    end

    def sync_symlink(link)
      source = resolve_path(link[:source_path], @repo_root)
      target = resolve_path(link[:target_path], @home_dir)

      result = {
        source: source.to_s,
        target: target.to_s,
        status: :unknown,
        message: nil
      }

      # Check source exists
      unless source.exist?
        result[:status] = :source_missing
        result[:message] = "Source missing: #{source}"
        return result
      end

      # Check target directory exists and is writable
      target_dir = target.dirname
      unless target_dir.exist?
        result[:status] = :target_dir_missing
        result[:message] = "Target directory missing: #{target_dir}"
        return result
      end

      unless target_dir.writable?
        result[:status] = :no_permission
        result[:message] = "No write permission: #{target_dir}"
        return result
      end

      # Set executable permission for bin files
      source.chmod(0755) if source.to_s.match?(/bin\/[^\/]+$/)

      # Handle existing target
      if target.exist? || target.symlink?
        if target.symlink?
          current_source = target.readlink
          current_source = current_source.expand_path(target.dirname) unless current_source.absolute?
          
          if current_source == source
            result[:status] = :already_correct
            result[:message] = "Already correct: #{target} -> #{source}"
            return result
          else
            result[:status] = :points_elsewhere
            result[:message] = "Points elsewhere: #{target} -> #{current_source}"
            return result
          end
        else
          result[:status] = :file_exists
          result[:message] = "File exists: #{target}"
          return result
        end
      end

      # Create symlink
      begin
        target.make_symlink(source)
        result[:status] = :created
        result[:message] = "Created: #{target} -> #{source}"
      rescue => e
        result[:status] = :failed
        result[:message] = "Failed to create #{target}: #{e.message}"
      end

      result
    end
  end
end