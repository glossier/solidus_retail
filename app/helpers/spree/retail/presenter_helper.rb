module PresenterHelper
  def present(object, presenter_type)
    klass = "#{presenter_type}_presenter".camelcase.constantize
    presenter = klass.new(object)
    yield presenter if block_given?
    presenter
  end
end
