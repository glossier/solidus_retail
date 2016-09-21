require 'spec_helper'

module ShopifyAPI
  RSpec.describe Transaction do
    subject(:transaction) do
      described_class.new(order_id: '0xCAFED00D')
    end

    it "knows its order ID" do
      expect(transaction.order_id).to eq '0xCAFED00D'
    end
  end
end
