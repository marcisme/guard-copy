module Guard
  class Copy
    class Target

      attr_reader :pattern, :options, :paths

      class << self

        # Resolve globs into targets.
        #
        # @param [String, Array<String>] globs one or more desired targets
        # @param [Symbol] mode target resolution mode, `:newest` or `:all`
        # @return [Array<Target>] the resolved targets
        #
        def resolve(globs, mode)
          Array.new.tap do |targets|
            Array(globs).each do |glob|
              if mode == :newest
                dirs = Dir[glob].sort_by { |f| File.mtime(f) }.last(1)
              else
                dirs = Dir[glob]
              end
              if dirs.any?
                #dirs.each do |dir|
                  #throw :task_has_failed if File.file?(dir)
                #end
                targets.concat(dirs)
              else
                UI.warning("Guard::Copy - '#{glob}' does not match a valid directory")
              end
            end
          end
        end

      end

      def initialize(pattern, options = {})
        raise ArgumentError, 'pattern cannot be nil' unless pattern
        raise ArgumentError, 'pattern cannot be empty' if pattern.empty?
        @pattern = pattern
        @options = {
          :glob => :all
        }.merge(options)
        @paths = []
      end

      def resolve
        @paths.clear
        if @options[:glob] == :newest
          @paths.concat(Dir[@pattern].sort_by { |f| File.mtime(f) }.last(1))
        else
          @paths.concat(Dir[@pattern])
        end
        @paths.any?
      end

    end
  end
end
