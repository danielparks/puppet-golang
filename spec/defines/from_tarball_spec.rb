# frozen_string_literal: true

require 'spec_helper'

describe 'golang::from_tarball' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { '/opt/go' }
      let(:params) { { source: 'https://go.dev/dl/foobar.tar.gz' } }
      let(:state_path) { '/opt/.go.source_url' }

      context "with default ensure on #{os}" do
        it { is_expected.to compile }
        it { is_expected.to contain_file('/opt/go').with_ensure('directory') }
        it { is_expected.to contain_file(state_path).with_ensure('file') }
      end

      context 'with ensure => present' do
        let(:params) { super().merge({ ensure: 'present' }) }

        it { is_expected.to compile }
        it { is_expected.to contain_file('/opt/go').with_ensure('directory') }
        it { is_expected.to contain_file(state_path).with_ensure('file') }
      end

      context 'with ensure => any_version' do
        let(:params) { super().merge({ ensure: 'any_version' }) }

        it { is_expected.to compile }
        it { is_expected.to contain_file('/opt/go').with_ensure('directory') }
        it { is_expected.not_to contain_file(state_path) }
      end

      context 'with ensure => absent' do
        let(:params) { super().merge({ ensure: 'absent' }) }

        it { is_expected.to compile }
        it { is_expected.to contain_file('/opt/go').with_ensure('absent') }
        it { is_expected.to contain_file(state_path).with_ensure('absent') }
      end
    end
  end
end
