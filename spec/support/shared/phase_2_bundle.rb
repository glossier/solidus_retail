RSpec.shared_context 'phase_2_bundle' do
  include_context 'spree_builders'

  let(:phase_2_bundle) { build_spree_product(name: 'Phase 2', parts: [phase_2_part_1, phase_2_part_2, phase_2_part_3]) }
  let(:phase_2_part_1) { build_spree_variant(sku: 'boybrow', product: phase_2_part_1_product) }
  let(:phase_2_part_2) { build_spree_variant(sku: 'GenG', product: phase_2_part_2_product) }
  let(:phase_2_part_3) { build_spree_variant(sku: 'GSC', product: phase_2_part_3_product) }

  let(:phase_2_part_1_product) { build_spree_product(name: 'Boy Brow', variants: [phase_2_part_1_variant_1, phase_2_part_1_variant_2]) }
  let(:phase_2_part_1_variant_1) { build_spree_variant(sku: 'GBB100-SET', option_values: [phase_2_part_1_option_value_1]) }
  let(:phase_2_part_1_variant_2) { build_spree_variant(sku: 'GBB200-SET', option_values: [phase_2_part_1_option_value_2]) }

  let(:phase_2_part_2_product) { build_spree_product(name: 'Generation G', variants: [phase_2_part_2_variant_1, phase_2_part_2_variant_2]) }
  let(:phase_2_part_2_variant_1) { build_spree_variant(sku: 'GML100-SET', option_values: [phase_2_part_2_option_value_1]) }
  let(:phase_2_part_2_variant_2) { build_spree_variant(sku: 'GML200-SET', option_values: [phase_2_part_2_option_value_2]) }

  let(:phase_2_part_3_product) { build_spree_product(name: 'Stretch Concealer', variants: [phase_2_part_3_variant_1, phase_2_part_3_variant_2]) }
  let(:phase_2_part_3_variant_1) { build_spree_variant(sku: 'GSC100-SET', option_values: [phase_2_part_3_option_value_1]) }
  let(:phase_2_part_3_variant_2) { build_spree_variant(sku: 'GSC200-SET', option_values: [phase_2_part_3_option_value_2]) }

  let(:phase_2_part_1_option_type) { build_spree_option_type(name: 'brow shade', presentation: 'shade') }
  let(:phase_2_part_1_option_value_1) { build_spree_option_value(name: 'Brown', presentation: 'Brown', option_type: phase_2_part_1_option_type) }
  let(:phase_2_part_1_option_value_2) { build_spree_option_value(name: 'Blond', presentation: 'Blond', option_type: phase_2_part_1_option_type) }

  let(:phase_2_part_2_option_type) { build_spree_option_type(name: 'lip shade', presentation: 'shade') }
  let(:phase_2_part_2_option_value_1) { build_spree_option_value(name: 'Cake', presentation: 'Cake', option_type: phase_2_part_2_option_type) }
  let(:phase_2_part_2_option_value_2) { build_spree_option_value(name: 'Jam', presentation: 'Jam', option_type: phase_2_part_2_option_type) }

  let(:phase_2_part_3_option_type) { build_spree_option_type(name: 'concealer shade', presentation: 'shade') }
  let(:phase_2_part_3_option_value_1) { build_spree_option_value(name: 'Light', presentation: 'Light', option_type: phase_2_part_3_option_type) }
  let(:phase_2_part_3_option_value_2) { build_spree_option_value(name: 'Medium', presentation: 'Medium', option_type: phase_2_part_3_option_type) }
end
