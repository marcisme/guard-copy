require 'guard/copy/error'

module Guard
  class Copy
    class BaseOperation

      def initialize(options)
        @options = options
      end

      def with_target_path(from_path, to_path)
        raise ::Guard::Copy::Error, "override #{ self.class.name }#with_target_path"
      end

      private

      attr_reader :options

    end
  end
end

