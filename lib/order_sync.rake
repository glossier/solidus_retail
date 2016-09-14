require 'solidus_retail/version'
require 'shopify_api'

module SolidusRetail
  extend Rake::DSL
  namespace :retail do
    desc 'sync orders'
    task generate_orders: :environment do
      begin
        now = Time.zone.now # now = Time.zone.parse('2015-07-18 03:00 UTC')
        from = now.at_beginning_of_day
        to = now.at_end_of_day
        puts "Fetching Shopify orders from #{from} to #{to}"
        ShopifyAPI::Order.where(limit: 250, created_at_min: from, created_at_max: to).each do |order|
          puts "Generating order for shopify order #{order.order_number}"
          SolidusRetail::Order::GeneratePosOrder.new(order).process
        end
      rescue => e
        puts "Error with #{e}"
      end
    end
  end
end
