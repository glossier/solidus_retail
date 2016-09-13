RSpec.shared_context 'spree_builders' do
  # TODO: This starts already to be out of hand. Think about fixing this
  def build_spree_product(id: 1, name: 'name', description: 'description',
                          master: build_spree_variant,
                          title: 'title',
                          vendor: 'vendor', slug: 'slug',
                          pos_product_id: '123',
                          created_at: build_date_time,
                          updated_at: build_date_time,
                          available_on: build_date_time,
                          parts: [],
                          variants: [])

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
    allow(product).to receive(:parts).and_return(parts)
    allow(product).to receive(:variants).and_return(variants)
    allow(product).to receive(:master).and_return(master)
    allow(product).to receive(:title).and_return(title)

    product
  end

  def build_spree_variant(product: nil, sku: 'sku',
                          weight: 10, weight_unit: 'oz',
                          price: 10.45, option_values: [],
                          updated_at: build_date_time)

    variant = double(:spree_variant)

    allow(variant).to receive(:product).and_return(product)
    allow(variant).to receive(:product_id).and_return(product.id) if product.present?
    allow(variant).to receive(:weight).and_return(weight)
    allow(variant).to receive(:weight_unit).and_return(weight_unit)
    allow(variant).to receive(:price).and_return(price)
    allow(variant).to receive(:sku).and_return(sku)
    allow(variant).to receive(:updated_at).and_return(updated_at)
    allow(variant).to receive(:option_values).and_return(option_values)

    variant
  end

  def build_spree_option_value(name: 'name', presentation: 'presentation', option_type: build_spree_option_type)
    option_value = double(:spree_option_value)

    allow(option_value).to receive(:name).and_return(name)
    allow(option_value).to receive(:presentation).and_return(presentation)
    allow(option_value).to receive(:option_type).and_return(option_type)

    option_value
  end

  def build_spree_option_type(name: 'name', presentation: 'presentation' )
    option_type = double(:spree_option_type)

    allow(option_type).to receive(:name).and_return(name)
    allow(option_type).to receive(:presentation).and_return(presentation)

    option_type
  end

  def build_date_time(year: 1991, month: 3, day: 24, hour: 12, minute: 0, second: 0)
    DateTime.new(year, month, day, hour, minute, second)
  end
end
