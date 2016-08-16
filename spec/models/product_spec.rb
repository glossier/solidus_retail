require 'spec_helper'

describe Spree::Product do
  it 'calls export_to_shopify method after save' do
    product = build(:product)
    expect(product).to receive(:export_to_shopify).once

    product.save
  end
end
