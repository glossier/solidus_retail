require 'spec_helper'

describe Shopify::OrderImporter do
  let!(:store) { create(:store) }
  let!(:stock_location) { create(:stock_location, admin_name: 'POPUP') }
  let!(:ny_state) { create(:state, state_code: 'NY') }
  let!(:variant) { create(:variant, sku: 'CAT3003') }
  let!(:user) { create(:user, email: 'charles@godynamo.com') }
  let!(:payment_method) { create(:credit_card_payment_method, name: 'Shopify') }
  let!(:shipping_method) do
    create(:shipping_method).tap do |shipping_method|
      shipping_method.zones.first.zone_members.create!(zoneable: country)
      shipping_method.calculator.set_preference(:amount, 10.0)
    end
  end
  let(:country) { ::Spree::Country.find_by(iso: 'US') }

  context 'complete shopify order' do
    let(:shopify_order_body) { ShopifyRequest.retrieve_complete_order }

    before do
      stub_request(:get, %r{myshopify.com}).to_return(body: shopify_order_body, status: 200)
      described_class.new('id-not-matter').perform
    end

    it 'creates a complete order' do
      order = ::Spree::Order.first
      expect(order.state).to eql('complete')
    end

    context 'when order\'s variant does not exists' do
      let(:logger_instance) { double('logger', error: true) }

      before do
        allow(Spree::Variant).to receive(:find_by).and_return(false)
        allow(Logger).to receive(:new).and_return(true)
      end

      it 'logs an error' do
        expect(logger_instance).to receive(:error).once
      end

      context 'and is the only variant on the order' do
        it 'does not complete the order' do
          order = ::Spree::Order.first
          expect(order.state).to eql('cart')
        end
      end
    end

    context 'when order\'s customer does not exists' do
      let(:logger_instance) { double('logger', error: true) }

      before do
        allow(Spree::User).to receive(:find_by).and_return(false)
        allow(Logger).to receive(:new).and_return(true)
      end

      it 'logs an error' do
        expect(logger_instance).to receive(:error).once
      end
    end

    it 'saves the glossier address as the ship address' do
      order = ::Spree::Order.first
      ship_address = order.ship_address
      expect(ship_address.address1).to eql('123 Lafayette St.')
    end

    it 'saves the bill address' do
      order = ::Spree::Order.first
      bill_address = order.bill_address
      expect(bill_address.address1).to eql('123 Lafayette Street')
    end

    it 'saves the customer' do
      order = ::Spree::Order.first
      user = order.user
      expect(user.email).to eql('charles@godynamo.com')
    end

    it 'saves the pos order identifier' do
      order = ::Spree::Order.first
      expect(order.number).to eql('1004')
      expect(order.pos_order_id).to eql('3523610883')
      expect(order.channel).to eql('shopify')
    end
  end
end
