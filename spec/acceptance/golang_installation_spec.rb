# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'defined type golang::installation' do
  context 'multiple root installs with linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/opt/go1.10.4':
          version => '1.10.4',
        }
        golang::installation { '/opt/go1.19.1':
          version => '1.19.1',
        }
        golang::linked_binaries { '/opt/go1.19.1':
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    ['1.10.4', '1.19.1'].each do |version|
      describe file("/opt/go#{version}") do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'root' }
      end

      describe file("/opt/go#{version}/bin/go") do
        it { is_expected.to be_file }
        it { is_expected.to be_executable }
        it { is_expected.to be_owned_by 'root' }
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
        golang::installation { '/opt/go1.10.4':
          version => '1.10.4',
        }
        golang::installation { '/opt/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '/opt/go1.10.4':
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    describe file('/opt/go1.10.4/bin/go') do
      it { is_expected.to be_file }
      it { is_expected.to be_executable }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/opt/go1.19.1') do
      it { is_expected.not_to exist }
    end

    describe file('/usr/local/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/opt/go1.10.4/bin/go' }
    end

    describe command('/usr/local/bin/go version') do
      its(:stdout) { is_expected.to start_with('go version go1.10.4 ') }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'multiple root uninstalls with linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/opt/go1.10.4':
          ensure => absent,
        }
        golang::installation { '/opt/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '/opt/go1.10.4':
          ensure   => absent,
          into_bin => '/usr/local/bin',
        }
      PUPPET
    end

    describe file('/opt/go1.10.4') do
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
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/home/user/go1.10.4':
          version => '1.10.4',
          owner   => 'user',
          group   => 'user',
          mode    => '0700',
        }

        golang::installation { '/home/user/go1.19.1':
          version => '1.19.1',
          owner   => 'user',
          group   => 'user',
          mode    => '0700',
        }

        golang::linked_binaries { '/home/user/go1.19.1':
          into_bin => '/home/user/bin',
        }

        group { 'user': }
        user { 'user':
          home       => '/home/user',
          gid        => 'user',
          managehome => true,
        }

        file { '/home/user/bin':
          ensure => directory,
          owner  => 'user',
          group  => 'user',
          mode   => '0755',
        }
      PUPPET
    end

    ['1.10.4', '1.19.1'].each do |version|
      describe file("/home/user/go#{version}") do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'user' }
        it { is_expected.to be_grouped_into 'user' }
        it { is_expected.to be_mode 700 } # WTF converted to octal
      end

      describe file("/home/user/go#{version}/bin/go") do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'user' }
        it { is_expected.to be_grouped_into 'user' }
        it { is_expected.to be_mode 755 } # WTF converted to octal
      end

      describe command("/home/user/go#{version}/bin/go version") do
        its(:stdout) { is_expected.to start_with("go version go#{version} ") }
        its(:stderr) { is_expected.to eq '' }
        its(:exit_status) { is_expected.to eq 0 }
      end
    end

    describe file('/home/user/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/home/user/go1.19.1/bin/go' }
    end
  end

  context 'multiple user installs with mixed ensure and linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/home/user/go1.10.4':
          version => '1.10.4',
          owner   => 'user',
          group   => 'user',
        }
        golang::installation { '/home/user/go1.19.1':
          ensure => absent,
        }
        golang::linked_binaries { '/home/user/go1.10.4':
          into_bin => '/home/user/bin',
        }
      PUPPET
    end

    describe file('/home/user/go1.10.4') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'user' }
      it { is_expected.to be_grouped_into 'user' }
      it { is_expected.to be_mode 755 } # WTF converted to octal
    end

    describe file('/home/user/go1.10.4/bin/go') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'user' }
      it { is_expected.to be_grouped_into 'user' }
      it { is_expected.to be_mode 755 } # WTF converted to octal
    end

    describe file('/home/user/go1.19.1') do
      it { is_expected.not_to exist }
    end

    describe file('/home/user/bin/go') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/home/user/go1.10.4/bin/go' }
    end

    describe command('/home/user/bin/go version') do
      its(:stdout) { is_expected.to start_with('go version go1.10.4 ') }
      its(:stderr) { is_expected.to eq '' }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'multiple user uninstalls with linked_binaries' do
    it do
      idempotent_apply(<<~'PUPPET')
        golang::installation { '/home/user/go1.10.4':
          ensure => absent,
          owner  => 'user',
          group  => 'user',
        }
        golang::installation { '/home/user/go1.19.1':
          ensure => absent,
          owner  => 'user',
          group  => 'user',
        }
        golang::linked_binaries { '/home/user/go1.10.4':
          ensure   => absent,
          into_bin => '/home/user/bin',
        }
      PUPPET
    end

    describe file('/home/user/go1.10.4') do
      it { is_expected.not_to exist }
    end

    describe file('/home/user/go1.19.1') do
      it { is_expected.not_to exist }
    end

    describe file('/home/user/bin/go') do
      it { is_expected.not_to exist }
    end
  end
end
