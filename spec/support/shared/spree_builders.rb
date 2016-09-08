RSpec.shared_context 'spree_builders' do
  # TODO: This starts already to be out of hand. Think about fixing this
  def build_spree_product(id: 1, name: 'name', description: 'description',
                          vendor: 'vendor', slug: 'slug',
                          pos_product_id: '123',
                          created_at: build_date_time,
                          updated_at: build_date_time,
                          available_on: build_date_time)

    product = double(:spree_product)

    allow(product).to receive(:id).and_return(id)
    allow(product).to receive(:pos_product_id).and_return(pos_product_id)
    allow(product).to receive(:name).and_return(name)
    allow(product).to receive(:description).and_return(description)
    allow(product).to receive(:created_at).and_return(created_at)
    allow(product).to receive(:updated_at).and_return(updated_at)
    allow(product).to receive(:available_on).and_return(available_on)
    allow(product).to receive(:vendor).and_return(vendor)
    allow(product).to receive(:slug).and_return(slug)

    product
  end

  def build_spree_variant(product: build_spree_product, sku: 'sku',
                          weight: 'weight', weight_unit: 'weight_unit',
                          price: 'price', option_values: [],
                          updated_at: build_date_time)

    variant = double(:spree_variant)

    allow(variant).to receive(:product).and_return(product)
    allow(variant).to receive(:product_id).and_return(product.id)
    allow(variant).to receive(:weight).and_return(weight)
    allow(variant).to receive(:weight_unit).and_return(weight_unit)
    allow(variant).to receive(:price).and_return(price)
    allow(variant).to receive(:sku).and_return(sku)
    allow(variant).to receive(:updated_at).and_return(updated_at)
    allow(variant).to receive(:option_values).and_return(option_values)

    variant
  end

  def build_spree_option_value(name: 'name', value: 'value')
    option = double(:spree_option)

    allow(option).to receive(:name).and_return(name)
    allow(option).to receive(:value).and_return(value)

    option
  end

  def build_date_time(year: 1991, month: 3, day: 24, hour: 12, minute: 0, second: 0)
    DateTime.new(year, month, day, hour, minute, second)
  end
end
