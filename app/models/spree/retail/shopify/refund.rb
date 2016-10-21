module Spree
  module Retail
    module Shopify
      module Refund
        extend self

        def create(order, return_items)
          create_return_authorization(order, return_items)
          customer_return = customer_return(return_items)
          create_reimbursement(customer_return)
        end

        private

        def create_return_authorization(order, return_items)
          Spree::Retail::Shopify::ReturnAuthorization.create(order, return_items)
        end

        def create_reimbursement(customer_return)
          Spree::Retail::Shopify::Reimbursement.create(customer_return)
        end

        def customer_return(return_items)
          Spree::Retail::Shopify::CustomerReturn.create(return_items)
        end
      end
    end
  end
end
