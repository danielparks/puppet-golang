# frozen_string_literal: true

require 'spec_helper_acceptance'

# This tarball contains entries owned by gopher (501) rather than root.
source_url = 'https://go.dev/dl/go1.10.4.darwin-amd64.tar.gz'

newer_source_url = 'https://go.dev/dl/go1.19.1.darwin-amd64.tar.gz'

describe 'defined type golang::from_tarball' do
  context 'repeated root installs:' do
    context 'default ensure with gopher-owned source' do
      it 'installs Go' do
        idempotent_apply(<<~"PUPPET")
          golang::from_tarball { '/opt/go':
            source => '#{source_url}',
          }
        PUPPET
      end

      describe file('/opt/go') do
        it { is_expected.to be_directory }
        its(:mode) { is_expected.to eq '755' }
        its(:owner) { is_expected.to eq 'root' }
      end

      describe file('/opt/.go.source_url') do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'root' }
        its(:content) { is_expected.to include "\n#{source_url}\n" }
      end

      describe file('/opt/go/bin/go') do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '755' }
        its(:owner) { is_expected.to eq 'root' }
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => present with gopher-owned source' do
      it 'causes no changes' do
        apply_manifest(<<~"PUPPET", catch_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => present,
            source => '#{source_url}',
          }
        PUPPET
      end

      describe file('/opt/.go.source_url') do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'root' }
        its(:content) { is_expected.to include "\n#{source_url}\n" }
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => any_version with newer source' do
      it 'causes no changes' do
        apply_manifest(<<~"PUPPET", catch_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => any_version,
            source => '#{newer_source_url}',
          }
        PUPPET
      end

      describe file('/opt/.go.source_url') do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'root' }
        its(:content) { is_expected.to include "\n#{source_url}\n" }
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.10.4' }
      end
    end

    context 'ensure => present with newer source' do
      it 'causes changes' do
        apply_manifest(<<~"PUPPET", expect_changes: true)
          golang::from_tarball { '/opt/go':
            ensure => present,
            source => '#{newer_source_url}',
          }
        PUPPET
      end

      describe file('/opt/.go.source_url') do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'root' }
        its(:content) { is_expected.to include "\n#{newer_source_url}\n" }
      end

      describe file('/opt/go/VERSION') do
        its(:content) { is_expected.to eq 'go1.19.1' }
      end
    end

    context 'ensure => absent' do
      it do
        idempotent_apply(<<~"PUPPET")
          golang::from_tarball { '/opt/go':
            ensure => absent,
            source => '#{newer_source_url}',
          }
        PUPPET
      end

      describe file('/opt/go') do
        it { is_expected.not_to exist }
      end

      describe file('/opt/.go.source_url') do
        it { is_expected.not_to exist }
      end

      describe file('/opt/go/VERSION') do
        it { is_expected.not_to exist }
      end
    end
  end

  context 'as a non-root user' do
    context 'default ensure with gopher-owned source' do
      it 'installs Go' do
        idempotent_apply(<<~"PUPPET")
          group { 'user': }
          user { 'user':
            home       => '#{home}/user',
            gid        => 'user',
            managehome => false,
          }

          file { '#{home}/user':
            ensure => directory,
            owner  => 'user',
            group  => 'user',
            mode   => '0755',
          }

          golang::from_tarball { '#{home}/user/go-install':
            source => '#{source_url}',
            owner  => 'user',
            group  => 'user',
            mode   => '0700',
          }
        PUPPET
      end

      describe file("#{home}/user/go-install") do
        it { is_expected.to be_directory }
        its(:mode) { is_expected.to eq '700' }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
      end

      describe file("#{home}/user/.go-install.source_url") do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'user' }
        its(:content) { is_expected.to include "\n#{source_url}\n" }
      end

      describe file("#{home}/user/go-install/bin/go") do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '755' }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
      end

      describe file("#{home}/user/go-install/VERSION") do
        its(:content) { is_expected.to eq 'go1.10.4' }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
      end

      context 'enforcing file ownership' do
        it 'chowns bin/go' do
          File.chown(0, 0, "#{home}/user/go-install/bin/go")
        end

        it 'reinstalls Go' do
          apply_manifest(<<~"PUPPET", expect_changes: true)
            golang::from_tarball { '#{home}/user/go-install':
              source => '#{source_url}',
              owner  => 'user',
              group  => 'user',
              mode   => '0700',
            }
          PUPPET
        end

        describe file("#{home}/user/go-install") do
          it { is_expected.to be_directory }
          its(:mode) { is_expected.to eq '700' }
          its(:owner) { is_expected.to eq 'user' }
          its(:group) { is_expected.to eq 'user' }
        end

        describe file("#{home}/user/go-install/bin/go") do
          it { is_expected.to be_file }
          its(:mode) { is_expected.to eq '755' }
          its(:owner) { is_expected.to eq 'user' }
          its(:group) { is_expected.to eq 'user' }
        end

        it 'does nothing' do
          apply_manifest(<<~"PUPPET", catch_changes: true)
            golang::from_tarball { '#{home}/user/go-install':
              source => '#{source_url}',
              owner  => 'user',
              group  => 'user',
              mode   => '0700',
            }
          PUPPET
        end
      end
    end

    context 'cleans up' do
      it 'uninstalls Go' do
        idempotent_apply(<<~"PUPPET")
          golang::from_tarball { '#{home}/user/go-install':
            ensure => absent,
            source => '#{source_url}',
          }
        PUPPET
      end

      describe file("#{home}/user/go-install") do
        it { is_expected.not_to exist }
      end

      describe file("#{home}/user/.go-install.source_url") do
        it { is_expected.not_to exist }
      end
    end
  end
end
