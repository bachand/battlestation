# frozen_string_literal: true

require 'battlestation'
require 'tmpdir'
require 'fileutils'

RSpec.describe Battlestation::Symlink do
  let(:temp_dir) { Dir.mktmpdir }
  let(:source_file) { File.join(temp_dir, 'source.txt') }
  let(:link_path) { File.join(temp_dir, 'link') }
  let(:symlink) { described_class.new(source_file, link_path) }

  before do
    # Create a source file for testing (unless it's supposed to not exist)
    unless source_file.include?('nonexistent') || source_file.include?('missing')
      File.write(source_file, 'test content')
    end
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#initialize' do
    it 'stores source and link paths as expanded Pathname objects' do
      expect(symlink.source_file).to be_a(Pathname)
      expect(symlink.link_pathname).to be_a(Pathname)
      expect(symlink.source_file.to_s).to eq(File.expand_path(source_file))
      expect(symlink.link_pathname.to_s).to eq(File.expand_path(link_path))
    end

    it 'handles relative paths by expanding them' do
      relative_source = 'relative_source.txt'
      relative_link = 'relative_link'
      
      Dir.chdir(temp_dir) do
        File.write(relative_source, 'content')
        symlink = described_class.new(relative_source, relative_link)
        
        expect(symlink.source_file.to_s).to eq(File.join(temp_dir, relative_source))
        expect(symlink.link_pathname.to_s).to eq(File.join(temp_dir, relative_link))
      end
    end
  end

  describe '#exists?' do
    context 'when symlink does not exist' do
      it 'returns false' do
        expect(symlink.exists?).to be false
      end
    end

    context 'when symlink exists and points to correct source' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'returns true' do
        expect(symlink.exists?).to be true
      end
    end

    context 'when symlink exists but points to different source' do
      let(:other_source) { File.join(temp_dir, 'other.txt') }
      
      before do
        File.write(other_source, 'other content')
        File.symlink(other_source, link_path)
      end

      it 'returns false' do
        expect(symlink.exists?).to be false
      end
    end

    context 'when target exists but is not a symlink' do
      before do
        File.write(link_path, 'regular file')
      end

      it 'returns false' do
        expect(symlink.exists?).to be false
      end
    end
  end

  describe '#target_exists?' do
    context 'when nothing exists at target path' do
      it 'returns false' do
        expect(symlink.target_exists?).to be false
      end
    end

    context 'when a regular file exists at target path' do
      before do
        File.write(link_path, 'content')
      end

      it 'returns true' do
        expect(symlink.target_exists?).to be true
      end
    end

    context 'when a symlink exists at target path' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'returns true' do
        expect(symlink.target_exists?).to be true
      end
    end

    context 'when a broken symlink exists at target path' do
      before do
        File.symlink('/nonexistent', link_path)
      end

      it 'returns true' do
        expect(symlink.target_exists?).to be true
      end
    end
  end

  describe '#create!' do
    context 'when conditions are ideal' do
      it 'creates the symlink successfully' do
        expect(symlink.create!).to be true
        expect(File.symlink?(link_path)).to be true
        expect(File.readlink(link_path)).to eq(source_file)
      end
    end

    context 'when source file does not exist' do
      let(:source_file) { File.join(temp_dir, 'nonexistent.txt') }

      it 'raises SymlinkError' do
        expect { symlink.create! }.to raise_error(
          Battlestation::SymlinkError, 
          /Source file does not exist/
        )
      end
    end

    context 'when target directory does not exist' do
      let(:link_path) { File.join(temp_dir, 'nonexistent_dir', 'link') }

      it 'raises SymlinkError' do
        expect { symlink.create! }.to raise_error(
          Battlestation::SymlinkError, 
          /Target directory does not exist/
        )
      end
    end

    context 'when target directory is not writable' do
      before do
        # Make the temp directory read-only
        File.chmod(0555, temp_dir)
      end

      after do
        # Restore write permissions for cleanup
        File.chmod(0755, temp_dir)
      end

      it 'raises SymlinkError with permission message' do
        expect { symlink.create! }.to raise_error(
          Battlestation::SymlinkError, 
          /No write permission for target directory.*Try running with sudo/m
        )
      end
    end

    context 'when target already exists as correct symlink' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'succeeds without error' do
        expect(symlink.create!).to be true
        expect(File.readlink(link_path)).to eq(source_file)
      end
    end

    context 'when target exists as symlink to different source' do
      let(:other_source) { File.join(temp_dir, 'other.txt') }
      
      before do
        File.write(other_source, 'other content')
        File.symlink(other_source, link_path)
      end

      it 'raises SymlinkError with details' do
        expect { symlink.create! }.to raise_error(
          Battlestation::SymlinkError, 
          /Symlink exists but points to different source.*Current.*Expected/m
        )
      end
    end

    context 'when target exists as regular file' do
      before do
        File.write(link_path, 'regular file content')
      end

      it 'raises SymlinkError' do
        expect { symlink.create! }.to raise_error(
          Battlestation::SymlinkError, 
          /Target path exists but is not a symlink/
        )
      end
    end
  end

  describe '#create' do
    context 'when creation succeeds' do
      it 'returns true' do
        expect(symlink.create).to be true
        expect(File.symlink?(link_path)).to be true
      end
    end

    context 'when creation fails' do
      let(:source_file) { File.join(temp_dir, 'nonexistent.txt') }

      it 'returns false without raising error' do
        expect(symlink.create).to be false
        expect(File.exist?(link_path)).to be false
      end
    end
  end

  describe '#remove!' do
    context 'when symlink does not exist' do
      it 'returns true' do
        expect(symlink.remove!).to be true
      end
    end

    context 'when symlink exists' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'removes the symlink and returns true' do
        expect(symlink.remove!).to be true
        expect(File.exist?(link_path)).to be false
      end
    end

    context 'when target exists but is not a symlink' do
      before do
        File.write(link_path, 'regular file')
      end

      it 'raises SymlinkError' do
        expect { symlink.remove! }.to raise_error(
          Battlestation::SymlinkError, 
          /Target exists but is not a symlink/
        )
      end
    end
  end

  describe '#remove' do
    context 'when removal succeeds' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'returns true' do
        expect(symlink.remove).to be true
        expect(File.exist?(link_path)).to be false
      end
    end

    context 'when removal fails' do
      before do
        File.write(link_path, 'regular file')
      end

      it 'returns false without raising error' do
        expect(symlink.remove).to be false
        expect(File.exist?(link_path)).to be true
      end
    end
  end

  describe '#status' do
    context 'when everything is ideal' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'returns complete status information' do
        status = symlink.status
        
        expect(status[:source_exists]).to be true
        expect(status[:target_exists]).to be true
        expect(status[:is_symlink]).to be true
        expect(status[:points_to_source]).to be true
        expect(status[:current_target]).to eq(source_file)
        expect(status[:expected_target]).to eq(source_file)
        expect(status[:target_directory_writable]).to be true
      end
    end

    context 'when symlink points to wrong target' do
      let(:other_source) { File.join(temp_dir, 'other.txt') }
      
      before do
        File.write(other_source, 'other')
        File.symlink(other_source, link_path)
      end

      it 'shows the mismatch' do
        status = symlink.status
        
        expect(status[:points_to_source]).to be false
        expect(status[:current_target]).to eq(other_source)
        expect(status[:expected_target]).to eq(source_file)
      end
    end
  end

  describe '#describe_status' do
    context 'when symlink exists and is correct' do
      before do
        File.symlink(source_file, link_path)
      end

      it 'returns positive message' do
        description = symlink.describe_status
        expect(description).to match(/✓ Symlink exists and points to correct source/)
      end
    end

    context 'when symlink exists but points to wrong target' do
      let(:other_source) { File.join(temp_dir, 'other.txt') }
      
      before do
        File.write(other_source, 'other')
        File.symlink(other_source, link_path)
      end

      it 'shows the mismatch details' do
        description = symlink.describe_status
        expect(description).to match(/✗ Symlink exists but points to different source/)
        expect(description).to include("Current:")
        expect(description).to include("Expected:")
      end
    end

    context 'when target exists but is not a symlink' do
      before do
        File.write(link_path, 'regular file')
      end

      it 'shows the conflict' do
        description = symlink.describe_status
        expect(description).to match(/✗ Target path exists but is not a symlink/)
      end
    end

    context 'when source does not exist' do
      let(:source_file) { File.join(temp_dir, 'missing.txt') }

      it 'shows the missing source error' do
        description = symlink.describe_status
        expect(description).to match(/✗ Source file does not exist/)
      end
    end

    context 'when ready to create' do
      it 'shows ready status' do
        description = symlink.describe_status
        expect(description).to match(/○ Ready to create symlink/)
      end
    end
  end

  describe 'integration with paths containing spaces' do
    let(:source_with_spaces) { File.join(temp_dir, 'source with spaces.txt') }
    let(:link_with_spaces) { File.join(temp_dir, 'link with spaces') }
    let(:symlink) { described_class.new(source_with_spaces, link_with_spaces) }

    before do
      File.write(source_with_spaces, 'content')
    end

    it 'handles paths with spaces correctly' do
      expect(symlink.create!).to be true
      expect(File.symlink?(link_with_spaces)).to be true
      expect(File.readlink(link_with_spaces)).to eq(source_with_spaces)
      expect(symlink.exists?).to be true
    end
  end
end
