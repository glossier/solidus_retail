require 'spec_helper'

describe Shopify::OrderImporter do
  let!(:store) { create(:store) }
  let!(:stock_location) { create(:stock_location, admin_name: 'POPUP') }
  let!(:ny_state) { create(:state, state_code: 'NY') }
  let!(:variant) { create(:variant, sku: 'CAT3003') }
  let!(:user) { create(:user, email: 'charles@godynamo.com') }
  let!(:payment_method) { create(:check_payment_method, name: 'Shopify') }
  let!(:shipping_method) do
    create(:shipping_method).tap do |shipping_method|
      shipping_method.zones.first.zone_members.create!(zoneable: country)
      shipping_method.calculator.set_preference(:amount, 10.0)
    end
  end
  let(:country) { Spree::Country.find_by(iso: 'US') }
  let(:logger_instance) { double('logger', error: true, info: true) }

  context 'with a complete shopify order' do
    let(:shopify_order_body) { ShopifyRequest.retrieve_complete_order }

    before do
      stub_request(:get, %r{myshopify.com}).to_return(body: shopify_order_body, status: 200)
    end

    subject { described_class.new('id-not-matter') }

    it 'creates a complete order' do
      subject.perform

      order = Spree::Order.first
      expect(order.state).to eql('complete')
    end

    context 'when order\'s variant is not found' do
      before do
        allow(Spree::Variant).to receive(:find_by).and_return(false)
        allow(Logger).to receive(:new).and_return(logger_instance)
      end

      it 'logs an error' do
        expect(logger_instance).to receive(:error)

        subject.perform
      end

      context 'and is the only variant on the order' do
        it 'does not complete the order' do
          subject.perform

          order = Spree::Order.first
          expect(order.state).to eql('cart')
        end
      end
    end

    context 'when order\'s customer does not exists' do
      before do
        allow(Spree.user_class).to receive(:find_by).and_return(false)
        allow(Logger).to receive(:new).and_return(logger_instance)
      end

      it 'logs an error' do
        expect(logger_instance).to receive(:error).once
        subject.perform
      end
    end

    it 'saves the glossier address as the ship address' do
      subject.perform

      order = Spree::Order.first
      ship_address = order.ship_address
      expect(ship_address.address1).to eql('123 Lafayette St.')
    end

    it 'saves the bill address' do
      subject.perform

      order = Spree::Order.first
      bill_address = order.bill_address
      expect(bill_address.address1).to eql('123 Lafayette Street')
    end

    context 'when the order\'s customer exists' do
      let!(:user) { create(:user, email: 'charles@godynamo.com') }

      it 'saves the customer' do
        subject.perform

        order = Spree::Order.first
        user = order.user
        expect(user.email).to eql('charles@godynamo.com')
      end
    end

    it 'saves the pos order identifier' do
      subject.perform

      order = Spree::Order.first
      expect(order.number).to eql('1004')
      expect(order.pos_order_id).to eql('3523610883')
      expect(order.channel).to eql('shopify')
    end
  end
end
