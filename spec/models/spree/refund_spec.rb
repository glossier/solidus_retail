require 'spec_helper'

module Spree
  RSpec.describe Refund do
    let(:refund) { create(:refund) }

    describe 'field' do
      it 'responds to pos_order_id' do
        expect(refund).to respond_to(:pos_order_id)
      end
    end
  end
end
