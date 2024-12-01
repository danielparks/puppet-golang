# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'defined type golang::installation' do
  context 'repeated root installs:' do
    context "ensure => '1.22.9'" do
      it 'installs Go' do
        idempotent_apply(<<~'PUPPET')
          golang::installation { '/opt/go':
            ensure => '1.22.9',
          }
        PUPPET
      end

      describe command('/opt/go/bin/go version') do
        its(:stdout) { is_expected.to start_with('go version go1.22.9 ') }
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    context 'ensure => present' do
      it 'causes no changes' do
        apply_manifest(<<~'PUPPET', catch_changes: true)
          golang::installation { '/opt/go':
            ensure => present,
          }
        PUPPET
      end

      describe command('/opt/go/bin/go version') do
        its(:stdout) { is_expected.to start_with('go version go1.22.9 ') }
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    context 'ensure => latest' do
      it 'causes changes' do
        apply_manifest(<<~'PUPPET', expect_changes: true)
          golang::installation { '/opt/go':
            ensure => latest,
          }
        PUPPET
      end

      describe command('/opt/go/bin/go version') do
        its(:stdout) do
          is_expected.to start_with('go version go').and(
            satisfy('go version >= 1.19.1') do |v|
              go_version = %r{\Ago version go(\d\S*) }.match(v)[1]
              Gem::Version.new(go_version) >= Gem::Version.new('1.19.1')
            end,
          )
        end
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    context 'ensure => latest again' do
      it 'causes no changes' do
        apply_manifest(<<~'PUPPET', catch_changes: true)
          golang::installation { '/opt/go':
            ensure => latest,
          }
        PUPPET
      end
    end

    context 'back to ensure => present' do
      it 'causes no changes' do
        apply_manifest(<<~'PUPPET', catch_changes: true)
          golang::installation { '/opt/go':
            ensure => present,
          }
        PUPPET
      end
    end

    context 'ensure => absent' do
      it do
        idempotent_apply(<<~'PUPPET')
          golang::installation { '/opt/go':
            ensure => absent,
          }
        PUPPET
      end
    end
  end

  context 'multiple root installs with linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/opt/go1.22.9':
          ensure => '1.22.9',
        }
        golang::installation { '/opt/go1.19.1':
          ensure => '1.19.1',
        }
        golang::linked_binaries { '/opt/go1.19.1':
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    ['1.22.9', '1.19.1'].each do |version|
      describe file("/opt/go#{version}") do
        it { is_expected.to be_directory }
        its(:owner) { is_expected.to eq 'root' }
      end

      describe file("/opt/.go#{version}.source_url") do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'root' }
        its(:content) { is_expected.to include "\nhttps://go.dev/dl/" }
      end

      describe file("/opt/go#{version}/bin/go") do
        it { is_expected.to be_file }
        it { is_expected.to be_executable }
        its(:owner) { is_expected.to eq 'root' }
      end

      describe command("/opt/go#{version}/bin/go version") do
        its(:stdout) { is_expected.to start_with("go version go#{version} ") }
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/opt/go1.19.1/bin/go' }
    end
  end

  context 'multiple root installs with mixed ensure and linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/opt/go1.22.9':
          ensure => '1.22.9',
        }
        golang::installation { '/opt/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '/opt/go1.22.9':
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    describe file('/opt/go1.22.9/bin/go') do
      it { is_expected.to be_file }
      it { is_expected.to be_executable }
      its(:owner) { is_expected.to eq 'root' }
    end

    describe file('/opt/go1.19.1') do
      it { is_expected.not_to exist }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/opt/go1.22.9/bin/go' }
    end

    describe command('/usr/local/bin/go version') do
      its(:stdout) { is_expected.to start_with('go version go1.22.9 ') }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'multiple root uninstalls with linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/opt/go1.22.9':
          ensure => absent,
        }
        golang::installation { '/opt/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '/opt/go1.22.9':
          ensure   => absent,
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    describe file('/opt/go1.22.9') do
      it { is_expected.not_to exist }
    end

    describe file('/opt/go1.19.1') do
      it { is_expected.not_to exist }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.not_to exist }
    end
  end

  context 'multiple user installs with linked_binaries' do
    it do
      idempotent_apply(<<~"PUPPET")
        golang::installation { '#{home}/user/go1.22.9':
          ensure => '1.22.9',
          owner  => 'user',
          group  => 'user',
          mode   => '0700',
        }

        golang::installation { '#{home}/user/go1.19.1':
          ensure => '1.19.1',
          owner  => 'user',
          group  => 'user',
          mode   => '0700',
        }

        golang::linked_binaries { '#{home}/user/go1.19.1':
          into_bin => '#{home}/user/bin',
        }

        group { 'user': }
        user { 'user':
          home       => '#{home}/user',
          gid        => 'user',
          managehome => false,
        }

        file { ['#{home}/user', '#{home}/user/bin']:
          ensure => directory,
          owner  => 'user',
          group  => 'user',
          mode   => '0755',
        }
      PUPPET
    end

    ['1.22.9', '1.19.1'].each do |version|
      describe file("#{home}/user/go#{version}") do
        it { is_expected.to be_directory }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
        it { is_expected.to be_mode 700 } # WTF converted to octal
      end

      describe file("#{home}/user/.go#{version}.source_url") do
        it { is_expected.to be_file }
        its(:mode) { is_expected.to eq '444' }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
        its(:content) { is_expected.to include "\nhttps://go.dev/dl/" }
      end

      describe file("#{home}/user/go#{version}/bin/go") do
        it { is_expected.to be_file }
        its(:owner) { is_expected.to eq 'user' }
        its(:group) { is_expected.to eq 'user' }
        it { is_expected.to be_mode 755 } # WTF converted to octal
      end

      describe command("#{home}/user/go#{version}/bin/go version") do
        its(:stdout) { is_expected.to start_with("go version go#{version} ") }
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    describe file("#{home}/user/bin/go") do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to "#{home}/user/go1.19.1/bin/go" }
    end
  end

  context 'multiple user installs with mixed ensure and linked_binaries' do
    it do
      idempotent_apply(<<~"PUPPET")
        golang::installation { '#{home}/user/go1.22.9':
          ensure => '1.22.9',
          owner  => 'user',
          group  => 'user',
        }
        golang::installation { '#{home}/user/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '#{home}/user/go1.22.9':
          into_bin => '#{home}/user/bin',
        }
      PUPPET
    end

    describe file("#{home}/user/go1.22.9") do
      it { is_expected.to be_directory }
      its(:owner) { is_expected.to eq 'user' }
      its(:group) { is_expected.to eq 'user' }
      it { is_expected.to be_mode 755 } # WTF converted to octal
    end

    describe file("#{home}/user/go1.22.9/bin/go") do
      it { is_expected.to be_file }
      its(:owner) { is_expected.to eq 'user' }
      its(:group) { is_expected.to eq 'user' }
      it { is_expected.to be_mode 755 } # WTF converted to octal
    end

    describe file("#{home}/user/go1.19.1") do
      it { is_expected.not_to exist }
    end

    describe file("#{home}/user/bin/go") do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to "#{home}/user/go1.22.9/bin/go" }
    end

    describe command("#{home}/user/bin/go version") do
      its(:stdout) { is_expected.to start_with('go version go1.22.9 ') }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'multiple user uninstalls with linked_binaries' do
    it do
      idempotent_apply(<<~"PUPPET")
        golang::installation { '#{home}/user/go1.22.9':
          ensure => absent,
          owner  => 'user',
          group  => 'user',
        }
        golang::installation { '#{home}/user/go1.19.1':
          ensure => absent,
          owner  => 'user',
          group  => 'user',
        }
        golang::linked_binaries { '#{home}/user/go1.22.9':
          ensure   => absent,
          into_bin => '#{home}/user/bin',
        }
      PUPPET
    end

    describe file("#{home}/user/go1.22.9") do
      it { is_expected.not_to exist }
    end

    describe file("#{home}/user/go1.19.1") do
      it { is_expected.not_to exist }
    end

    describe file("#{home}/user/bin/go") do
      it { is_expected.not_to exist }
    end
  end
end
