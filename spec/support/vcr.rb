VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    match_requests_on: [
      :method,
      VCR.request_matchers
    ]
  }

  c.around_http_request do |request|
    if request.shopify?
      VCR.use_cassette 'shopify',
        record: :new_episodes,
        allow_playback_repeats: false,
        match_requests_on: [:method, :host, :path],
        &request
    else
      c.log 'UNHANDLED EXTERNAL REQUEST' if request.unhandled?

      request.proceed
    end
  end
end

module VCRRequestExtensions
  def shopify?
    /myshopify\.com/ =~ uri
  end
end

VCR::Request.prepend(VCRRequestExtensions)
