module Spree
  module Retail
    module Shopify
      module Refund
        extend self

        def create(order, return_items)
          create_return_authorization(order, return_items)
          create_reimbursement(return_items)
        end

        private

        def create_return_authorization(order, return_items)
          ReturnAuthorization.create(order, return_items)
        end

        def create_reimbursement
          Reimbursement.create(customer_return)
        end

        def customer_return(return_items)
          CustomerReturn.create(return_items)
        end
      end
    end
  end
end
