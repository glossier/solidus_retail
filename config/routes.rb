Spree::Core::Engine.routes.draw do
  namespace :retail do
    namespace :shopify do
      namespace :hooks do
        resource :order, only: :create
        resource :user, only: :create
      end
    end
  end
end
