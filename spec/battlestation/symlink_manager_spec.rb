# frozen_string_literal: true

require 'battlestation'
require 'tmpdir'
require 'fileutils'
require 'yaml'

RSpec.describe Battlestation::SymlinkManager do
  let(:temp_dir) { Dir.mktmpdir }
  let(:config_file) { File.join(temp_dir, 'symlinks.yaml') }
  let(:repo_root) { File.join(temp_dir, 'repo') }
  let(:home_dir) { File.join(temp_dir, 'home') }

  before do
    FileUtils.mkdir_p([repo_root, home_dir])
    
    # Create test source files
    FileUtils.mkdir_p(File.join(repo_root, 'config/dotfiles'))
    File.write(File.join(repo_root, 'config/dotfiles/gitconfig'), '[user]\n  name = Test')
    FileUtils.mkdir_p(File.join(repo_root, 'bin'))
    File.write(File.join(repo_root, 'bin/test-script'), '#!/bin/bash\necho test')
    
    # Create test config file
    config = [
      { 'target_path' => '.gitconfig', 'source_path' => 'config/dotfiles/gitconfig' },
      { 'target_path' => 'test-script', 'source_path' => 'bin/test-script' }
    ]
    File.write(config_file, config.to_yaml)
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#create_all' do
    it 'creates symlinks from YAML configuration' do
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: false)
      
      expect(manager.create_all).to be true
      expect(File.symlink?(File.join(home_dir, '.gitconfig'))).to be true
      expect(File.symlink?(File.join(home_dir, 'test-script'))).to be true
      expect(File.readlink(File.join(home_dir, '.gitconfig'))).to eq(File.join(repo_root, 'config/dotfiles/gitconfig'))
    end

    it 'sets executable permissions on bin files' do
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: false)
      
      File.chmod(0644, File.join(repo_root, 'bin/test-script'))
      expect(File.executable?(File.join(repo_root, 'bin/test-script'))).to be false
      
      manager.create_all
      expect(File.executable?(File.join(repo_root, 'bin/test-script'))).to be true
    end

    it 'handles existing correct symlinks gracefully' do
      target = File.join(home_dir, '.gitconfig')
      source = File.join(repo_root, 'config/dotfiles/gitconfig')
      File.symlink(source, target)
      
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: true)
      expect(manager.create_all).to be true
    end

    it 'fails gracefully when source is missing' do
      File.unlink(File.join(repo_root, 'config/dotfiles/gitconfig'))
      
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: false)
      expect(manager.create_all).to be false
    end
  end

  describe '#status' do
    it 'shows status of symlinks' do
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: false)
      
      expect { manager.status }.to output(/Ready to create/).to_stdout
    end
  end

  describe '#remove_all' do
    it 'removes existing symlinks' do
      manager = described_class.new(config_file, repo_root: repo_root, home_dir: home_dir, verbose: false)
      manager.create_all
      
      expect(File.symlink?(File.join(home_dir, '.gitconfig'))).to be true
      manager.remove_all
      expect(File.exist?(File.join(home_dir, '.gitconfig'))).to be false
    end
  end

  describe 'error handling' do
    it 'raises error for missing config file' do
      expect {
        described_class.new('/nonexistent/config.yaml', verbose: false)
      }.to raise_error(/Configuration file not found/)
    end

    it 'raises error for invalid YAML structure' do
      File.write(config_file, { 'not' => 'an array' }.to_yaml)
      
      expect {
        described_class.new(config_file, verbose: false)
      }.to raise_error(/must be an array/)
    end

    it 'raises error for missing required fields' do
      File.write(config_file, [{ 'target_path' => 'only_target' }].to_yaml)
      
      expect {
        described_class.new(config_file, verbose: false)
      }.to raise_error(/must have.*source_path.*target_path/)
    end
  end
end