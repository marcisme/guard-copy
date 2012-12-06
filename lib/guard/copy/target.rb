module Guard
  class Copy
    class Target

      attr_reader :pattern, :options, :paths

      # Initialize a new target
      #
      # @param [String] pattern the pattern for this target
      # @option options [Symbol] glob target resolution mode, `:newest` or `:all`
      #
      def initialize(pattern, options = {})
        raise ArgumentError, 'pattern cannot be nil' unless pattern
        raise ArgumentError, 'pattern cannot be empty' if pattern.empty?
        @pattern = pattern
        @options = {
          :glob => :all
        }.merge(options)
        @paths = []
      end

      # Resolve the target into one or more paths
      #
      # @return [Boolean] true if the pattern resolved to any paths
      def resolve
        @paths.clear
        if @options[:glob] == :newest
          @paths.concat(Dir[@pattern].sort_by { |f| File.mtime(f) }.last(1))
        else
          @paths.concat(Dir[@pattern])
        end
        @paths.any?
      end

      # @return [Boolean] true if the pattern is an absolute path
      def absolute?
        @pattern.start_with?('/')
      end

      # @return [String] path pattern
      def pattern
        @pattern
      end

    end
  end
end
