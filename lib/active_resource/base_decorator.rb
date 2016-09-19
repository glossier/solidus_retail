module ActiveResource
  module BaseDecorator
    module ClassMethods
      def find_by(*arguments)
        return nil if arguments.detect { |a| a[:id].nil? }
        values = where(*arguments)
        values.any? ? values.first : nil
      end

      def find_or_initialize_by(arguments, &block)
        find_by(arguments) || new(arguments.except(:id), &block)
      end
    end

    def self.prepended(base)
      base.extend ClassMethods
    end
  end
end

ActiveResource::Base.prepend ActiveResource::BaseDecorator
