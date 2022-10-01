# frozen_string_literal: true

require 'spec_helper'

describe 'Golang::Ensure' do
  ['present', 'absent', 'latest', '1.1', '1.0rc10'].each do |valid|
    it "considers '#{valid}' valid" do
      is_expected.to allow_value(valid)
    end
  end

  [:undef, true, '0', 'Present'].each do |invalid|
    it "considers '#{invalid}' invalid" do
      is_expected.not_to allow_value(invalid)
    end
  end
end
