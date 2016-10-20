module Spree
  module Retail
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
          Spree::Retail::RedcarpetHTMLRenderer.new
        end
      end
    end
  end
end
