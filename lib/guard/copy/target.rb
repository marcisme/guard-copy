module Guard
  class Copy
    class Target

      attr_reader :pattern, :paths, :glob

      # Initialize a new target
      #
      # @param [String] pattern the pattern for this target
      # @option options [Symbol] glob target resolution mode, `:newest` or `:all`
      #
      def initialize(pattern, options = {})
        raise ArgumentError, 'pattern cannot be nil' unless pattern
        raise ArgumentError, 'pattern cannot be empty' if pattern.empty?
        @pattern = pattern
        @glob = options[:glob] || :all
        @expand_pattern = !options[:mkpath]
        @paths = []
      end

      # Resolve the target into one or more paths
      def resolve!
        paths.clear
        if expand_pattern?
          expand_pattern
        else
          paths << pattern
        end
        warn_if_empty
      end

      # @return [Boolean] true if the pattern is an absolute path
      def absolute?
        pattern.start_with?('/')
      end

      private

      def expand_pattern?; @expand_pattern; end

      def expand_pattern
        case glob
        when :newest
          paths.concat(Dir[pattern].sort_by { |f| File.mtime(f) }.last(1))
        when :all
          paths.concat(Dir[pattern])
        end
      end

      def warn_if_empty
        unless paths.any?
          UI.warning("Guard::Copy - '#{pattern}' does not match a valid directory")
        end
      end

    end
  end
end
