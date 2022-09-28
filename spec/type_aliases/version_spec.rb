# frozen_string_literal: true

require 'spec_helper'

describe 'Golang::Version' do
  ['1.19.1', '1.3', '1.3rc1', '1.900.1rc10', '1'].each do |valid|
    it "considers '#{valid}' valid" do
      is_expected.to allow_value(valid)
    end
  end

  ["1.19.1\n", '1..1', '0', '01.2', '-1.1', '', 'foo'].each do |invalid|
    it "considers '#{invalid}' invalid" do
      is_expected.not_to allow_value(invalid)
    end
  end
end
