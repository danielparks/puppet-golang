# frozen_string_literal: true

require 'spec_helper'

describe 'golang' do
  let(:pre_condition) { <<~'PUPPET' }
    # Overide golang::latest_version to avoid dependence on https://go.dev.
    function golang::latest_version($_url) { '1.0.0' }

    # Make deprecations testable with rspec-puppet.
    function deprecation($key, $warning) {
      notify { $key:
        message => $warning,
      }
    }
  PUPPET

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default' do
        it { is_expected.to compile }
      end
    end
  end

  context 'on first os found' do
    let(:facts) { on_supported_os.first[1] }

    ['present', 'latest', '1.19.1', 'absent'].each do |ensure_|
      context "ensure => '#{ensure_}'" do
        let(:params) do
          { ensure: ensure_ }
        end

        describe 'and nothing else' do
          it { is_expected.to compile }
        end

        describe "version => '1.19.1'" do
          let(:params) do
            super().merge({ version: '1.19.1' })
          end

          it { is_expected.to compile }
          it do
            is_expected.to(
              create_notify('$golang::version').with_message(%r{deprecated}),
            )
          end
        end

        describe "source => 'http://no-such-host'" do
          let(:params) do
            super().merge({ source: 'http://no-such-host' })
          end

          it { is_expected.to compile }
          it do
            is_expected.to(
              create_notify('$golang::source').with_message(%r{deprecated}),
            )
          end
        end
      end
    end
  end
end
