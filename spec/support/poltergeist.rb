require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    js_errors: false,
    inspector: true,
    timeout: 240,
    url_blacklist: %w(
      typekit.net
      fontdeck.com
      facebook.net
      facebook.com
      optimizely.com
      ravenjs.com
      google.com
      googleapis.com
      googleadservices.com
      googletagmanager.com
      google-analytics.com)
  )
end

Capybara.raise_server_errors   = false
Capybara.always_include_port   = true
Capybara.javascript_driver     = :poltergeist
Capybara.default_max_wait_time = 10
Capybara.server_port           = 61_454
