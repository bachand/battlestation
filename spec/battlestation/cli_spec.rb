require 'spec_helper'
require_relative '../../lib/battlestation/cli'

describe Battlestation::CLI do

  describe '#run' do
    it 'runs each setup step and returns shell exit status' do
      expect(subject).to receive(:install_terminal_theme).with(kind_of(Pathname))
      expect(subject).to receive(:configure_xcode)
      expect(subject).to receive(:run_legacy_setup_script).with(kind_of(Pathname))
      expect(subject).to receive(:install_python)
      expect(subject).to receive(:install_aws_cli)
      expect(subject).to receive(:update_homebrew)
      expect(subject).to receive(:install_packages)
      expect(subject).to receive(:configure_fzf)
      expect(subject).to receive(:install_ruby).with('2.7.6')
      expect(subject).to receive(:set_ruby_version).with('2.7.6')
      expect(subject).to receive(:install_gems).with(kind_of(Pathname))

      allow(Output).to receive(:put_success)
      allow(Output).to receive(:put_info)
    end
  end
end
