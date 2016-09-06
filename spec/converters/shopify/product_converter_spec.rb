require 'spec_helper'

module Shopify
  RSpec.describe ProductConverter do
    let(:spree_product) { build_spree_product }

    describe '.initialize' do
      subject { described_class.new(spree_product) }

      it "successfully does it's thing" do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(spree_product).to_hash }

      it { expect(subject[:title]).to eql('name') }
      it { expect(subject[:body_html]).to eql('description') }
      it { expect(subject[:created_at]).to eql(build_date_time) }
      it { expect(subject[:updated_at]).to eql(build_date_time) }
      it { expect(subject[:published_at]).to eql(build_date_time) }
      it { expect(subject[:vendor]).to eql('vendor') }
      it { expect(subject[:handle]).to eql('slug') }
    end

    private

    def build_spree_product(name: 'name', description: 'description',
                            vendor: 'vendor', slug: 'slug',
                            created_at: build_date_time,
                            updated_at: build_date_time,
                            available_on: build_date_time)

      product = double(:spree_product)

      allow(product).to receive(:name).and_return(name)
      allow(product).to receive(:description).and_return(description)
      allow(product).to receive(:created_at).and_return(created_at)
      allow(product).to receive(:updated_at).and_return(updated_at)
      allow(product).to receive(:available_on).and_return(available_on)
      allow(product).to receive(:vendor).and_return(vendor)
      allow(product).to receive(:slug).and_return(slug)

      product
    end

    def build_date_time(year: 1991, month: 3, day: 24)
      DateTime.new(year, month, day)
    end
  end
end
