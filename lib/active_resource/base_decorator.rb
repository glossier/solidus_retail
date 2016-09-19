module ActiveResource
  module BaseDecorator
    module ClassMethods
      def find_by_id(id, options = {})
        find(id, options)
      rescue ActiveResource::ResourceNotFound
        return nil
      end

      def find_or_initialize_by_id(id, options = {})
        attributes = options.key?(:params) ? options[:params] : options
        find_by_id(id, options) || new(attributes)
      end
    end

    def self.prepended(base)
      base.extend ClassMethods
    end
  end
end

ActiveResource::Base.prepend ActiveResource::BaseDecorator
