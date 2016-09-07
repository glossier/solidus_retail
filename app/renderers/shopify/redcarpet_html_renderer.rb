require 'redcarpet'

module Shopify
  class RedcarpetHTMLRenderer
    def initialize(options: {}, extensions: {})
      @options = options
      @extensions = extensions

      @renderer = Redcarpet::Render::HTML.new(default_options)
      @converter = Redcarpet::Markdown.new(@renderer, default_extensions)
    end

    def render(content)
      @converter.render(content).strip
    end

    private

    attr_accessor :options, :extensions, :renderer, :converter

    def default_options
      {
        filter_html:     false,
        hard_wrap:       true,
        link_attributes: { rel: 'nofollow', target: '_blank' },
        space_after_headers: true,
        fenced_code_blocks: true,
        no_images: true,
        no_styles: true
      }.merge(options)
    end

    def default_extensions
      {
        autolink:           true,
        superscript:        true,
        disable_indented_code_blocks: true
      }.merge(extensions)
    end
  end
end
