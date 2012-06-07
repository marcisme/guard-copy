require 'guard'
require 'guard/guard'
require 'guard/copy/version'
require 'fileutils'

module Guard
  class Copy < Guard

    attr_reader :targets

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      if watchers.empty?
        watchers << ::Guard::Watcher.new(%r{^#{options[:from]}/.*$})
      else
        watchers.each { |w| normalize_watcher(w, options[:from]) }
      end
      options[:to] = Array(options[:to]).freeze
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      validate_from
      validate_to
      @targets = resolve_targets
      if @targets.any?
        UI.info("Guard::Copy will copy files from:")
        UI.info("  #{options[:from]}")
        UI.info("to:")
        @targets.each { |target| UI.info("  #{target}") }
      end
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_changes has failed
    def run_on_changes(paths)
      validate_targets
      paths.each do |from_path|
        @targets.each do |target|
          to_path = from_path.sub(@options[:from], target)
          validate_to_path(to_path)
          FileUtils.cp(from_path, to_path)
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    def run_on_removals(paths)
    end

    private

    def normalize_watcher(watcher, from)
      unless watcher.pattern.source =~ %r{^\^#{from}/.*}
        normalized_source = watcher.pattern.source.sub(%r{^\^?(#{from})?/?}, "^#{from}/")
        UI.info('Guard::Copy is changing watcher pattern:')
        UI.info("  #{watcher.pattern.source}")
        UI.info('to:')
        UI.info("  #{normalized_source}")
        watcher.pattern = Regexp.new(normalized_source)
      end
    end

    def validate_from
      unless options[:from]
        UI.error('Guard::Copy - :from option is required')
        throw :task_has_failed
      end
      if File.file?(options[:from])
        UI.error("Guard::Copy - '#{options[:from]}' is a file and must be a directory")
        throw :task_has_failed
      end
      unless File.directory?(options[:from])
        UI.error('Guard::Copy - :from option does not contain a valid directory')
        throw :task_has_failed
      end
    end

    def validate_to
      if options[:to].empty?
        UI.error('Guard::Copy - :to option is required')
        throw :task_has_failed
      end
      if options[:to].include?(options[:from])
        UI.error('Guard::Copy - :to must not include :from')
        throw :task_has_failed
      end
    end

    def validate_targets
      if @targets.empty?
        UI.error('Guard::Copy - cannot copy, no valid :to directories')
        throw :task_has_failed
      end
    end

    def validate_to_path(to_path)
      to_dir = File.dirname(to_path)
      unless File.directory?(to_dir)
        UI.error('Guard::Copy - cannot copy, directory path does not exist:')
        UI.error("  #{to_dir}")
        throw :task_has_failed
      end
    end

    def resolve_targets
      Array.new.tap do |targets|
        options[:to].each do |to|
          if @options[:glob] == :newest
            dirs = Dir[to].sort_by { |f| File.mtime(f) }.last(1)
          else
            dirs = Dir[to]
          end
          if dirs.any?
            #dirs.each do |dir|
              #throw :task_has_failed if File.file?(dir)
            #end
            targets.concat(dirs)
          else
            UI.warning("Guard::Copy - '#{to}' does not match a valid directory")
          end
        end
      end
    end

  end
end
