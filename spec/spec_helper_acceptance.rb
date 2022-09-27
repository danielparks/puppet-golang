# frozen_string_literal: true

# Created to use litmus per:
# https://puppetlabs.github.io/litmus/Converting-modules-to-use-Litmus.html

require 'puppet_litmus'
PuppetLitmus.configure!

require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))
