# frozen_string_literal: true

require 'spec_helper'

describe 'golang::linked_binaries' do
  let(:pre_condition) { <<~'PUPPET' }
    golang::from_tarball { '/usr/local/go':
      source => 'https://go.dev/dl/foo.tar.gz',
    }
  PUPPET

  let(:title) { '/usr/local/go' }
  let(:params) { { into_bin: '/usr/local/bin' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
