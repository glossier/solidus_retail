require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.ignore_localhost = true

  c.default_cassette_options = {
    record: ENV.key?('TRAVIS') ? :none : :new_episodes,
    match_requests_on: %i(method path)
  }
end
