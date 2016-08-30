Spree::Order.instance_eval do
  def by_channel(name)
    where(channel: name)
  end
end
