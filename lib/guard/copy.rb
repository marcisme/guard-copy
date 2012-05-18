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
      @targets = Array(options[:to]).freeze
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      unless options[:from]
        throw :task_has_failed, 'Guard::Copy requires a valid source directory in :from'
      end
      UI.info("Guard::Copy will copy files from '#{options[:from]}' to:")
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
          target_dirs = target_dirs(target)
          if target_dirs.empty?
            UI.error("'#{target}' does not match any directories")
          else
            copy(from_path, target_dirs)
          end
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_deletion has failed
    def run_on_deletion(paths)
    end

    private

    def target_dirs(target)
      if @options[:glob] == :newest
        Dir[target].sort_by { |f| File.mtime(f) }.last(1)
      else
        Dir[target]
      end
    end

    def copy(from_path, target_dirs)
      target_dirs.each do |target_dir|
        if File.directory?(target_dir)
          to_path = from_path.sub(@options[:from], target_dir)
          FileUtils.cp(from_path, to_path)
        else
          UI.error("'#{target_dir}' is not a directory")
        end
      end
    end

  end
end
