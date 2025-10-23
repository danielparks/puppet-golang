# frozen_string_literal: true

require 'spec_helper'

describe 'golang::installation' do
  let(:pre_condition) { <<~'PUPPET' }
    # Override golang::latest_version to avoid dependence on https://go.dev.
    function golang::latest_version($_url) { '1.0.0' }
  PUPPET

  let(:title) { '/usr/local/go' }
  let(:params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
