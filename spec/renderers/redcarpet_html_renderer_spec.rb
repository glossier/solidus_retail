require 'spec_helper'

module Shopify
  RSpec.describe RedcarpetHTMLRenderer do
    include_context 'spree_builders'

    let(:product) { build_spree_product }
    subject { described_class.new }

    describe '.initialize' do
      it 'returns an instance of the redcarpet html renderer' do
        expect(subject).to be_a described_class
      end
    end

    describe '.render' do
      describe 'when the content is nil' do
        it 'returns an empty string' do
          result = subject.render(nil)
          expect(result).to eql('')
        end
      end

      describe 'when passes a non-nil content' do
        before do
          allow_any_instance_of(Redcarpet::Markdown).to receive(:render).and_return('string')
        end

        it 'returns a string that is not empty' do
          result = subject.render('hello')
          expect(result).not_to be_empty
        end
      end
    end
  end
end
