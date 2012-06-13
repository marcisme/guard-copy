module Guard
  class Copy
    class Target

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

    end
  end
end
