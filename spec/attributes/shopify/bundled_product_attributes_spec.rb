require 'spec_helper'

module Shopify
  RSpec.describe BundledProductAttributes do
    include_context 'phase_2_bundle'

    describe '.attributes' do
      subject { described_class.new(phase_2_bundle) }

      before do
        WebMock.allow_net_connect!
      end
      after do
        WebMock.disable_net_connect!
      end

      it 'dassad' do
        product = ShopifyAPI::Product.new.update_attributes(subject.attributes)

        true
      end
    end
  end
end
