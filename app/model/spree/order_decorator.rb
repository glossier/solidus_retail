Spree::Order.class_eval do
  def by_channel(name)
    where(channel: name)
  end
end
