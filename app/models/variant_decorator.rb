Spree::Variant.class_eval do
  # Generic method that can get overwritten by Solidus Application in order to
  # define what is the image we want to have uploaded on the POS system.
  def default_pos_image
    return '' if images.empty?

    images.first
  end

  def default_pos_stock_location
    Spree::StockLocation.first
  end

  def count_on_hand_for(stock_location)
    stock_items.find_by(stock_location_id: stock_location.id).count_on_hand
  end
end
