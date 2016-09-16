require 'spec_helper'

module Shopify
  RSpec.describe ProductConverter do
    include_context 'spree_builders'

    let(:product) { build_spree_product }

    describe '.initialize' do
      subject { described_class.new(product: product) }

      it 'returns an instance of the product converter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(product: product).to_hash }

      it 'converts the name field to the title field' do
        expect(subject[:title]).to eql('name')
      end

      it 'converts the description field to the body html field' do
        expect(subject[:body_html]).to eql('description')
      end

      it 'keeps the same created_at property' do
        expect(subject[:created_at]).to eql(build_date_time)
      end

      it 'keeps the same updated_at property' do
        expect(subject[:updated_at]).to eql(build_date_time)
      end

      it 'keeps the same published_at property' do
        expect(subject[:published_at]).to eql(build_date_time)
      end

      it 'keeps the same vendor property' do
        expect(subject[:vendor]).to eql('vendor')
      end

      it 'converts the slug field to the handle field' do
        expect(subject[:handle]).to eql('slug')
      end
    end
  end
end
