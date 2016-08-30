Spree::Core::Engine.routes.draw do
  namespace :shopify_hook do
    resource :order, only: :create
  end
end
