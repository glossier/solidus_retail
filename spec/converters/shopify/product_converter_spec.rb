require 'spec_helper'

module Shopify
  RSpec.describe ProductConverter do
    include_context 'spree_builders'

    let(:product) { build_spree_product }

    describe '.initialize' do
      subject { described_class.new(product: product) }

      it "successfully does it's thing" do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(product: product).to_hash }

      it { expect(subject[:title]).to eql('name') }
      it { expect(subject[:body_html]).to eql('description') }
      it { expect(subject[:created_at]).to eql(build_date_time) }
      it { expect(subject[:updated_at]).to eql(build_date_time) }
      it { expect(subject[:published_at]).to eql(build_date_time) }
      it { expect(subject[:vendor]).to eql('vendor') }
      it { expect(subject[:handle]).to eql('slug') }
    end
  end
end
