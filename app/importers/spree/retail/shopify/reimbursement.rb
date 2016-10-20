module Spree
  module Retail
    module Shopify
      module Reimbursement
        class << self
          def create(customer_return)
            reimbursement = build_reimbursement_from(customer_return)
            reimbursement.save
            reimbursement.pos_refunded!
            reimbursement.perform!
          end

          private

          def stock_location_to_refund
            Spree::StockLocation.first
          end

          def build_reimbursement_from(customer_return)
            Spree::Reimbursement.build_from_customer_return(customer_return)
          end
        end
      end
    end
  end
end
