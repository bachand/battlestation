# frozen_string_literal: true

require 'battlestation'
require 'tmpdir'
require 'fileutils'
require 'stringio'

RSpec.describe Battlestation::SymlinkManager do
  let(:temp_dir) { Dir.mktmpdir }
  let(:source1) { File.join(temp_dir, 'source1.txt') }
  let(:source2) { File.join(temp_dir, 'source2.txt') }
  let(:link1) { File.join(temp_dir, 'link1') }
  let(:link2) { File.join(temp_dir, 'link2') }
  let(:manager) { described_class.new(verbose: false) }

  before do
    File.write(source1, 'content1')
    File.write(source2, 'content2')
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#initialize' do
    it 'creates a manager with empty symlinks list' do
      expect(manager).to be_instance_of(described_class)
    end

    it 'accepts verbose option' do
      verbose_manager = described_class.new(verbose: true)
      quiet_manager = described_class.new(verbose: false)
      
      expect(verbose_manager).to be_instance_of(described_class)
      expect(quiet_manager).to be_instance_of(described_class)
    end
  end

  describe '#add_symlink' do
    it 'adds symlinks to the internal list' do
      manager.add_symlink(source1, link1)
      manager.add_symlink(source2, link2)
      
      statuses = manager.check_all
      expect(statuses.length).to eq(2)
      expect(statuses[0][:source]).to eq(source1)
      expect(statuses[0][:target]).to eq(link1)
      expect(statuses[1][:source]).to eq(source2)
      expect(statuses[1][:target]).to eq(link2)
    end
  end

  describe '#create_all' do
    context 'when all symlinks can be created successfully' do
      before do
        manager.add_symlink(source1, link1)
        manager.add_symlink(source2, link2)
      end

      it 'creates all symlinks and returns true' do
        expect(manager.create_all).to be true
        expect(File.symlink?(link1)).to be true
        expect(File.symlink?(link2)).to be true
        expect(File.readlink(link1)).to eq(source1)
        expect(File.readlink(link2)).to eq(source2)
      end
    end

    context 'when some symlinks fail to create' do
      let(:nonexistent_source) { File.join(temp_dir, 'nonexistent.txt') }

      before do
        manager.add_symlink(source1, link1)  # This should succeed
        manager.add_symlink(nonexistent_source, link2)  # This should fail
      end

      it 'creates what it can and returns false' do
        expect(manager.create_all).to be false
        expect(File.symlink?(link1)).to be true
        expect(File.exist?(link2)).to be false
      end
    end

    context 'when no symlinks are registered' do
      it 'returns true' do
        expect(manager.create_all).to be true
      end
    end
  end

  describe '#check_all' do
    before do
      manager.add_symlink(source1, link1)
      manager.add_symlink(source2, link2)
    end

    context 'when symlinks exist and are correct' do
      before do
        File.symlink(source1, link1)
        File.symlink(source2, link2)
      end

      it 'returns status showing all are working' do
        statuses = manager.check_all
        expect(statuses.length).to eq(2)
        expect(statuses[0][:status][:points_to_source]).to be true
        expect(statuses[1][:status][:points_to_source]).to be true
      end
    end

    context 'when symlinks do not exist' do
      it 'returns status showing they need to be created' do
        statuses = manager.check_all
        expect(statuses.length).to eq(2)
        expect(statuses[0][:status][:points_to_source]).to be false
        expect(statuses[0][:status][:target_exists]).to be false
        expect(statuses[1][:status][:points_to_source]).to be false
        expect(statuses[1][:status][:target_exists]).to be false
      end
    end
  end

  describe '#remove_all' do
    before do
      manager.add_symlink(source1, link1)
      manager.add_symlink(source2, link2)
      File.symlink(source1, link1)
      File.symlink(source2, link2)
    end

    it 'removes all symlinks and returns true' do
      expect(File.exist?(link1)).to be true
      expect(File.exist?(link2)).to be true
      
      expect(manager.remove_all).to be true
      
      expect(File.exist?(link1)).to be false
      expect(File.exist?(link2)).to be false
    end

    context 'when some targets are not symlinks' do
      before do
        File.unlink(link1)
        File.write(link1, 'regular file')  # Make link1 a regular file
      end

      it 'handles errors gracefully and returns false' do
        expect(manager.remove_all).to be false
        expect(File.exist?(link1)).to be true  # Regular file should still exist
        expect(File.exist?(link2)).to be false  # Symlink should be removed
      end
    end
  end

  describe '#show_status' do
    let(:output) { StringIO.new }

    before do
      # Capture stdout
      allow($stdout).to receive(:puts) { |msg| output.puts(msg) }
      allow(Output).to receive(:put_info) { |msg| output.puts("INFO: #{msg}") }
      allow(Output).to receive(:put_success) { |msg| output.puts("SUCCESS: #{msg}") }
      allow(Output).to receive(:put_error) { |msg| output.puts("ERROR: #{msg}") }
    end

    context 'when no symlinks are configured' do
      it 'shows no symlinks message' do
        manager.show_status
        expect(output.string).to include("INFO: No symlinks configured")
      end
    end

    context 'when all symlinks are working' do
      before do
        manager.add_symlink(source1, link1)
        manager.add_symlink(source2, link2)
        File.symlink(source1, link1)
        File.symlink(source2, link2)
      end

      it 'shows success status' do
        manager.show_status
        output_content = output.string
        expect(output_content).to include("INFO: Symlink Status Report:")
        expect(output_content).to include("SUCCESS: All 2 symlinks are working correctly")
      end
    end

    context 'when some symlinks are broken' do
      before do
        manager.add_symlink(source1, link1)
        manager.add_symlink(source2, link2)
        File.symlink(source1, link1)  # Only create one symlink
      end

      it 'shows error status' do
        manager.show_status
        output_content = output.string
        expect(output_content).to include("INFO: Symlink Status Report:")
        expect(output_content).to include("ERROR: 1/2 symlinks are working correctly")
      end
    end
  end

  describe 'verbose output' do
    let(:verbose_manager) { described_class.new(verbose: true) }
    let(:output) { StringIO.new }

    before do
      allow($stdout).to receive(:puts) { |msg| output.puts(msg) }
      allow(Output).to receive(:put_success) { |msg| output.puts("SUCCESS: #{msg}") }
      allow(Output).to receive(:put_error) { |msg| output.puts("ERROR: #{msg}") }
      
      verbose_manager.add_symlink(source1, link1)
    end

    it 'outputs verbose messages during creation' do
      verbose_manager.create_all
      output_content = output.string
      expect(output_content).to include("Creating symlink:")
      expect(output_content).to include("SUCCESS:")
    end
  end

  describe 'integration test with various edge cases' do
    it 'handles paths with spaces correctly' do
      source_with_spaces = File.join(temp_dir, 'source with spaces.txt')
      link_with_spaces = File.join(temp_dir, 'link with spaces')
      File.write(source_with_spaces, 'content')
      
      manager.add_symlink(source_with_spaces, link_with_spaces)
      
      expect(manager.create_all).to be true
      expect(File.symlink?(link_with_spaces)).to be true
      expect(File.readlink(link_with_spaces)).to eq(source_with_spaces)
      
      statuses = manager.check_all
      expect(statuses[0][:status][:points_to_source]).to be true
    end
  end
end