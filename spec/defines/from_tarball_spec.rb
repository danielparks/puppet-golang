# frozen_string_literal: true

require 'spec_helper'

describe 'golang::from_tarball' do
  let(:title) { '/usr/local/go' }
  let(:params) { { source: 'https://go.dev/dl/foobar.tar.gz' } }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_file('/usr/local/.go.source_url') }
    end
  end
end
