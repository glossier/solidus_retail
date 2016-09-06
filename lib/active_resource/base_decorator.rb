module ActiveResource
  module BaseDecorator
    def find_by(*arguments)
      where(*arguments).take
    end

    def find_or_initialize_by(attributes, &block)
      find_by(attributes) || new(attributes, &block)
    end
  end
end

ActiveResource::Base.prepend ActiveResource::BaseDecorator
