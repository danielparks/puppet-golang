# frozen_string_literal: true

require 'spec_helper'

describe 'golang::state_file' do
  it { runs_with('/usr/local/go', returns: '/usr/local/.go.source_url') }
  it { runs_with('/go', returns: '/.go.source_url') }
  it { runs_with('/./go', returns: '/./.go.source_url') }
  it { runs_with('/../go', returns: '/../.go.source_url') }
  it { runs_with('/...', returns: '/.....source_url') }

  it { runs_with('/', fails: %r{No reasonable default state_file}) }
  it { runs_with('/.', fails: %r{No reasonable default state_file}) }
  it { runs_with('/..', fails: %r{No reasonable default state_file}) }
end
