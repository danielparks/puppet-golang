# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'golang' do
  context 'install with a specific version' do
    it do
      idempotent_apply(<<~'END')
        class { 'golang':
          version => '1.10.4',
        }
      END
    end

    describe file('/usr/local/go') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/usr/local/go/bin/go') do
      it { is_expected.to be_file }
      it { is_expected.to be_executable }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/usr/local/go/bin/go' }
    end

    describe command('/usr/local/bin/go version') do
      its(:stdout) { is_expected.to match(%r{\Ago version go1.10.4 }) }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'install without parameters' do
    it { idempotent_apply('include golang') }

    describe file('/usr/local/go') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/usr/local/go/bin/go') do
      it { is_expected.to be_file }
      it { is_expected.to be_executable }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/usr/local/go/bin/go' }
    end

    describe command('/usr/local/bin/go version') do
      its(:stdout) { is_expected.to match(%r{\Ago version }) }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe 'uninstall' do
    it do
      # These tests are run in order, so this isn’t strictly necessary. However,
      # I’d prefer to avoid relying on the previous tests, so here it is. In
      # order to avoid unnecessary changes, this should match the last test run
      apply_manifest('include golang')

      idempotent_apply(<<~'END')
        class { 'golang':
          ensure => absent,
        }
      END
    end

    describe file('/usr/local/go') do
      it { is_expected.not_to exist }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.not_to exist }
    end
  end
end
