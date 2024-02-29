# frozen_string_literal: true

# Created to use litmus per:
# https://puppetlabs.github.io/content-and-tooling-team/docs/litmus/usage/converting-modules-to-use-litmus/

require 'puppet_litmus'
PuppetLitmus.configure!

# For some reason litmusimage/ubuntu:22.04 doesn’t come with sudo.
RSpec.configure do |config|
  if RUBY_PLATFORM.include?('linux')
    config.before(:suite) do
      litmus = Class.new.extend(PuppetLitmus)
      litmus.apply_manifest("package { 'sudo': }", catch_failures: true)
    end
  end
end

def home
  if RUBY_PLATFORM.include?('darwin')
    '/Users'
  else
    '/home'
  end
end

require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))
