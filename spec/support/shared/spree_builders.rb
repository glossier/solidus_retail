RSpec.shared_context 'spree_builders' do
  def build_spree_product(id: 1, name: 'name', description: 'description',
                          vendor: 'vendor', slug: 'slug',
                          created_at: build_date_time,
                          updated_at: build_date_time,
                          available_on: build_date_time)

    product = double(:spree_product)

    allow(product).to receive(:id).and_return(id)
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
