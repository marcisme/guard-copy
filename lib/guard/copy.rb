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
      if options[:to].empty?
        UI.error('Guard::Copy - :to option is required')
        throw :task_has_failed
      end
      if options[:to].include?(options[:from])
        UI.error('Guard::Copy - :to must not include :from')
        throw :task_has_failed
      end
      if resolve_targets.any?
        UI.info("Guard::Copy will copy files from:")
        UI.info("  #{options[:from]}")
        UI.info("to:")
        @targets.each { |target| UI.info("  #{target}") }
      else
        UI.error("Guard::Copy - :to option does not contain a valid directory")
        throw :task_has_failed
      end
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
      @targets = Array.new.tap do |targets|
        options[:to].each do |to|
          if @options[:glob] == :newest
            dirs = Dir[to].sort_by { |f| File.mtime(f) }.last(1)
          else
            dirs = Dir[to]
          end
          if dirs.any?
            targets.concat(dirs)
          else
            UI.warning("Guard::Copy - '#{to}' does not match a valid directory")
          end
        end
      end
    end

  end
end
