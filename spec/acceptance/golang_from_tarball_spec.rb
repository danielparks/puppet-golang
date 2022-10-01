# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'defined type golang::from_tarball' do
  context 'repeated root installs:' do
    context 'default ensure with 1.10.4 source' do
      it 'installs Go' do
        idempotent_apply(<<~'PUPPET')
          golang::from_tarball { '/opt/go':
            source => 'https://go.dev/dl/go1.10.4.linux-amd64.tar.gz',
          }
        PUPPET
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => present' do
      it 'causes no changes' do
        apply_manifest(<<~'PUPPET', catch_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => present,
            source => 'https://go.dev/dl/go1.10.4.linux-amd64.tar.gz',
          }
        PUPPET
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => any_version with 1.19.1 source' do
      it 'causes no changes' do
        apply_manifest(<<~'PUPPET', catch_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => any_version,
            source => 'https://go.dev/dl/go1.19.1.linux-amd64.tar.gz',
          }
        PUPPET
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => present with 1.19.1 source' do
      it 'causes changes' do
        apply_manifest(<<~'PUPPET', expect_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => present,
            source => 'https://go.dev/dl/go1.19.1.linux-amd64.tar.gz',
          }
        PUPPET
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.19.1' }
      end
    end

    context 'ensure => absent' do
      it do
        idempotent_apply(<<~'PUPPET')
          golang::from_tarball { '/opt/go':
            ensure => absent,
            source => 'https://go.dev/dl/go1.19.1.linux-amd64.tar.gz',
          }
        PUPPET
      end

      describe file('/opt/go/VERSION') do
        it { is_expected.not_to exist }
      end
    end
  end
end
