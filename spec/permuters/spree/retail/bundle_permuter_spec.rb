require 'spec_helper'

module Spree
  module Retail
    RSpec.describe BundlePermuter do
      include_context 'phase_2_bundle'

      describe '#all_option_values_per_part' do
        subject { described_class.all_option_values_per_part(phase_2_part_1) }

        it 'returns all the possible option values for the part' do
          expect(subject.count).to eql(2)
        end

        describe 'for a single option value hash' do
          subject { described_class.all_option_values_per_part(phase_2_part_1).first }

          it 'contains a sku' do
            expect(subject[:sku]).to eql('GBB100-SET')
          end

          it 'contains an option type text' do
            expect(subject[:option_type_text]).to eql('brow shade')
          end

          it 'contains an option value text' do
            expect(subject[:option_value_text]).to eql('Brown')
          end
        end
      end

      describe '#all_option_values_per_bundle' do
        subject { described_class.all_option_values_per_bundle(new_phase_2_bundle) }

        it 'returns all the possible option values per bundle' do
          expect(subject.count).to eql(3)
        end

        it 'returns all the possible option values per part' do
          expect(subject.first.count).to eql(2)
          expect(subject.second.count).to eql(2)
          expect(subject.third.count).to eql(2)
        end

        describe 'for a single option value hash' do
          let(:option_values_per_bundle) { described_class.all_option_values_per_bundle(new_phase_2_bundle) }
          let(:option_values_per_part) { option_values_per_bundle.first }
          subject { option_values_per_part.first }

          it 'contains a sku' do
            expect(subject[:sku]).to eql('GBB100-SET')
          end

          it 'contains an option type text' do
            expect(subject[:option_type_text]).to eql('brow shade')
          end

          it 'contains an option value text' do
            expect(subject[:option_value_text]).to eql('Brown')
          end
        end
      end

      describe '#all_option_values_permutation' do
        subject { described_class.all_option_values_permutation(new_phase_2_bundle) }

        it 'returns a correct count of permutation' do
          expect(subject.count).to eql(8)
          (0..7).each do |i|
            expect(subject[i].count).to eql(3)
          end
        end

        describe 'for a single option value hash' do
          let(:option_values_per_bundle) { described_class.all_option_values_permutation(new_phase_2_bundle) }
          let(:option_values_per_part) { option_values_per_bundle.first }
          subject { option_values_per_part.first }

          it 'contains a sku' do
            expect(subject[:sku]).to eql('GBB100-SET')
          end

          it 'contains an option type text' do
            expect(subject[:option_type_text]).to eql('brow shade')
          end

          it 'contains an option value text' do
            expect(subject[:option_value_text]).to eql('Brown')
          end
        end
      end
    end
  end
end
