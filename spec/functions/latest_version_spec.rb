# frozen_string_literal: true

require 'spec_helper'

describe 'golang::latest_version' do
  it do
    # This actually makes a request
    is_expected.to run
      .with_params('https://go.dev/dl/?mode=json')
      .and_return(%r{\A\d+\.[0-9.]*\d\z})
  end

  it do
    is_expected.to run
      .with_params('http://no-such-host')
      .and_raise_error(Puppet::Error)
  end
end
