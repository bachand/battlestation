# frozen_string_literal: true

require 'battlestation'
require 'tmpdir'
require 'fileutils'

RSpec.describe Battlestation::SymlinkSync do
  let(:temp_dir) { Dir.mktmpdir }
  let(:repo_root) { File.join(temp_dir, 'repo') }
  let(:home_dir) { File.join(temp_dir, 'home') }

  before do
    FileUtils.mkdir_p([repo_root, home_dir])
    
    # Create test source files
    FileUtils.mkdir_p(File.join(repo_root, 'config/dotfiles'))
    File.write(File.join(repo_root, 'config/dotfiles/gitconfig'), '[user]\n  name = Test')
    File.write(File.join(repo_root, 'config/dotfiles/zshrc'), 'export PATH=/usr/local/bin:$PATH')
    FileUtils.mkdir_p(File.join(repo_root, 'bin'))
    File.write(File.join(repo_root, 'bin/git-cleanup'), '#!/bin/bash\necho cleanup')
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#sync' do
    it 'creates symlinks and returns results' do
      sync = described_class.new(repo_root: repo_root, home_dir: home_dir)
      results = sync.sync
      
      expect(results).to be_an(Array)
      expect(results.length).to eq(7) # All defined symlinks
      
      # Check that some were created successfully
      created_results = results.select { |r| r[:status] == :created }
      expect(created_results.length).to be > 0
      
      # Check structure of results
      results.each do |result|
        expect(result).to have_key(:source)
        expect(result).to have_key(:target)
        expect(result).to have_key(:status)
        expect(result).to have_key(:message)
      end
    end

    it 'sets executable permissions on bin files' do
      sync = described_class.new(repo_root: repo_root, home_dir: home_dir)
      
      File.chmod(0644, File.join(repo_root, 'bin/git-cleanup'))
      expect(File.executable?(File.join(repo_root, 'bin/git-cleanup'))).to be false
      
      sync.sync
      expect(File.executable?(File.join(repo_root, 'bin/git-cleanup'))).to be true
    end

    it 'handles existing correct symlinks' do
      target = File.join(home_dir, '.gitconfig')
      source = File.join(repo_root, 'config/dotfiles/gitconfig')
      File.symlink(source, target)
      
      sync = described_class.new(repo_root: repo_root, home_dir: home_dir)
      results = sync.sync
      
      gitconfig_result = results.find { |r| r[:target] == target }
      expect(gitconfig_result[:status]).to eq(:already_correct)
    end

    it 'handles missing source files' do
      File.delete(File.join(repo_root, 'config/dotfiles/gitconfig'))
      
      sync = described_class.new(repo_root: repo_root, home_dir: home_dir)
      results = sync.sync
      
      gitconfig_result = results.find { |r| r[:target].end_with?('.gitconfig') }
      expect(gitconfig_result[:status]).to eq(:source_missing)
    end

    it 'handles permission issues' do
      # Make home directory read-only
      File.chmod(0555, home_dir)
      
      sync = described_class.new(repo_root: repo_root, home_dir: home_dir)
      results = sync.sync
      
      # Should have permission errors for targets in home dir
      home_results = results.select { |r| r[:target].start_with?(home_dir) }
      expect(home_results.any? { |r| r[:status] == :no_permission }).to be true
      
      # Restore permissions for cleanup
      File.chmod(0755, home_dir)
    end
  end
end