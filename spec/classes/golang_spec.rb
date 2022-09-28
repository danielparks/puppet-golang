# frozen_string_literal: true

require 'spec_helper'

describe 'golang' do
  let(:pre_condition) { <<~'PUPPET' }
    # Overide golang::latest_version to avoid dependence on https://go.dev.
    function golang::latest_version($_url) { '1.0.0' }
  PUPPET

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default' do
        it { is_expected.to compile }
      end

      describe 'ensure => absent' do
        let(:params) do
          { ensure: 'absent' }
        end

        it { is_expected.to compile }
      end
    end
  end
end
