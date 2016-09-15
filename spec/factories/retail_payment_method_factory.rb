FactoryGirl.define do
  factory :retail_payment_method, class: Spree::Gateway::ShopifyGateway do
    name 'Shopify'
  end
end
