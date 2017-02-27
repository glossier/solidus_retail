module Spree
  module Retail
    module Shopify
      module Reimbursement
        extend self

        def create(customer_return)
          reimbursement = build_reimbursement_from(customer_return)
          reimbursement.reimbursement_tax_calculator = reimbursement_tax_calculator
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

        def reimbursement_tax_calculator
          Spree::Retail::ReimbursementTaxCalculator
        end
      end
    end
  end
end
