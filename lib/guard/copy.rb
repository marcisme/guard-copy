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
      # watchers are currently ignored
      watchers << ::Guard::Watcher.new(%r{#{options[:from]}/.*})
      options[:to] = Array(options[:to]).freeze
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      unless options[:from]
        throw :task_has_failed, 'Guard::Copy - :from option is required'
      end
      unless File.directory?(options[:from])
        throw :task_has_failed, 'Guard::Copy - :from option does not contain a valid directory'
      end
      if options[:to].empty?
        throw :task_has_failed, 'Guard::Copy - :to option is required'
      end
      @targets = resolve_targets
      UI.info("Guard::Copy will copy files from:")
      UI.info("  #{options[:from]}")
      UI.info("to:")
      @targets.each { |target| UI.info("  #{target}") }
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      paths.each do |from_path|
        @targets.each do |target|
          to_path = from_path.sub(@options[:from], target)
          FileUtils.cp(from_path, to_path)
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_deletion has failed
    def run_on_deletion(paths)
    end

    private

    def resolve_targets
      Array.new.tap do |dirs|
        options[:to].each do |to|
          if @options[:glob] == :newest
            dirs.concat(Dir[to].sort_by { |f| File.mtime(f) }.last(1))
          else
            dirs.concat(Dir[to])
          end
        end
        if dirs.empty?
          throw :task_has_failed, 'Guard::Copy - :to option does not contain a valid directory'
        end
      end
    end

  end
end
