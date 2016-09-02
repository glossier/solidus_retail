module Shopify
  class ProductPresenter < Delegator
    def description
      html_renderer.render(model.description)
    end

    def vendor
      'Default Vendor'
    end

    private

    def html_renderer
      Shopify::RedcarpetHTMLRenderer.new
    end
  end
end
