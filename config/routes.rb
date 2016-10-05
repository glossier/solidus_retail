Spree::Core::Engine.routes.draw do
  namespace :retail do
    namespace :shopify do
      namespace :hooks do
        resource :order, only: :create
      end
    end
  end
end
