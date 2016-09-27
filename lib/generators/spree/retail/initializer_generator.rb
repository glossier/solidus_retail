class InitializerGenerator < Rails::Generators::Base
  desc 'This generator creates an initializer file at config/initializers'
  def create_initializer_file
    template 'config/initializers/spree_retail.rb', 'config/initializers/spree_retail.rb'
  end
end
