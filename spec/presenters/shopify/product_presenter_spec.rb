require 'spec_helper'

module Shopify
  RSpec.describe ProductPresenter do
    include Spree::Retail::PresenterHelper
    include_context 'spree_builders'

    let(:product) { build_spree_product(description: 'La-Mulana') }
    subject { present(product, :product) }

    describe '.description' do
      let(:renderer_instance) { double('renderer') }

      before do
        allow(renderer_instance).to receive(:render).with(an_instance_of(String)).and_return('Carpe diem')
        allow_any_instance_of(ProductPresenter).to receive(:html_renderer).and_return(renderer_instance)
      end

      it 'returns a rendered string' do
        result = subject.description
        expect(result).to eql('Carpe diem')
      end
    end

    describe '.vendor' do
      it 'returns the default vendor string' do
        result = subject.vendor
        expect(result).to eql('Default Vendor')
      end
    end
  end
end
