module Spree
  module Retail
    module Shopify
      class Refund
        class << self
          def create(spree_order, return_items)
            create_return_authorization(spree_order, return_items)
            create_reimbursement(return_items)
          end

          private

          def create_return_authorization(spree_order, return_items)
            ReturnAuthorization.create(spree_order, return_items)
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
end
