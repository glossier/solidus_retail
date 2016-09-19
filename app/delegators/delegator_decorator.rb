module DelegatorDecorator
  def initialize(obj)
    super obj
    @delegate_sd_obj = obj
  end

  def __getobj__
    @delegate_sd_obj
  end
  alias_method :model, :__getobj__

  def __setobj__(obj)
    @delegate_sd_obj = obj
  end
end

Delegator.prepend DelegatorDecorator
