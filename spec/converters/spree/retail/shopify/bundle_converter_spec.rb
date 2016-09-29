require 'spec_helper'

module Spree::Retail::Shopify
  RSpec.describe BundleConverter do
    include_context 'phase_2_bundle'

    let(:option_types) do
      [phase_2_part_1_option_type.name,
       phase_2_part_2_option_type.name,
       phase_2_part_3_option_type.name]
    end

    describe '.initialize' do
      subject { described_class.new(bundle: phase_2_bundle, option_types: option_types) }

      it 'returns an instance of the bundle converter' do
        expect(subject).to be_a described_class
      end
    end

    describe '.to_hash' do
      subject { described_class.new(bundle: phase_2_bundle, option_types: option_types).to_hash }

      it 'converts the name key to the title key' do
        expect(subject[:title]).to eql('Phase 2')
      end

      it 'converts the description key to the body html key' do
        expect(subject[:body_html]).to eql('description')
      end

      it 'keeps the same created_at value' do
        expect(subject[:created_at]).to eql(build_date_time)
      end

      it 'keeps the same updated_at value' do
        expect(subject[:updated_at]).to eql(build_date_time)
      end

      it 'keeps the same published_at value' do
        expect(subject[:published_at]).to eql(build_date_time)
      end

      it 'keeps the same vendor value' do
        expect(subject[:vendor]).to eql('vendor')
      end

      it 'converts the slug value to the handle value' do
        expect(subject[:handle]).to eql('slug')
      end

      it 'has all the options types' do
        options = subject[:options]

        expect(options.count).to eql(3)

        expect(options.first[:name]).to eql('brow shade')
        expect(options.second[:name]).to eql('lip shade')
        expect(options.third[:name]).to eql('concealer shade')
      end
    end
  end
end
