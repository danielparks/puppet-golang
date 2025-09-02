# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# @summary Get the lastest stable version number for Go
#
# Makes a request to the passed URL to find the latest stable version of Go. The
# request will be cached for 10 minutes, so repeated calls to this function will
# return the same thing for at least that amount of time.
Puppet::Functions.create_function(:"golang::latest_version") do
  # @param url
  #   The URL to check. This should usually be `'https://go.dev/dl/?mode=json'`
  #   unless you are getting Go from elsewhere.
  # @return [Golang::Version]
  #   The version number, e.g. `'1.19.1'`.
  # @raise Puppet::Error
  #   If the URL is invalid, the request failed, it didn’t understand the
  #   returned JSON, or it couldn’t find a version that was listed as stable.
  dispatch :latest_version do
    param 'Stdlib::HTTPUrl', :url
    return_type 'Golang::Version'
  end

  def latest_version(url)
    time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @@golang_latest_version_cache ||= {} # rubocop:disable Style/ClassVars

    # Cache latest version for 600 seconds (10 minutes)
    if !@@golang_latest_version_cache[url] \
        || time - @@golang_latest_version_cache[url][:time] >= 600
      @@golang_latest_version_cache[url] = {
        time:,
        version: load_latest_version(url),
      }
    end

    @@golang_latest_version_cache[url][:version]
  end

  def load_latest_version(url)
    begin
      response = Net::HTTP.get_response(URI(url))
    rescue => e
      raise Puppet::Error, "Could not connect to #{url.inspect} to get " \
        "latest Go version: #{e}"
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise Puppet::Error, "Bad response from #{url.inspect} while getting " \
        "latest Go version: #{response.code} #{response.message}"
    end

    begin
      JSON.parse(response.body).each do |version_info|
        unless version_info['stable']
          next
        end

        return version_info['version'].delete_prefix('go')
      end
    rescue
      raise Puppet::Error, "Unexpected or invalid JSON from #{url.inspect} " \
        'while getting latest Go version'
    end

    raise Puppet::Error, "Could not find a stable Go version at #{url.inspect}"
  end
end
