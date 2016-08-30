require 'spec_helper'

describe Spree::Order do
  describe 'class methods' do
    let!(:order_channel_web) { create(:order, channel: 'web') }
    let!(:order_channel_shopify) { create(:order, channel: 'shopify') }

    subject { described_class }

    it 'responds to by_channel' do
      expect(subject).to respond_to(:by_channel)
    end

    it 'filters by channel' do
      result = subject.by_channel('web')
      expect(result.count).to be(1)
      expect(result.first.channel).to be_eql('web')
    end
  end
end
