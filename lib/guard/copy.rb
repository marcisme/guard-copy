require 'guard'
require 'guard/guard'
require 'fileutils'

module Guard
  class Copy < Guard

    autoload :Target, 'guard/copy/target'

    attr_reader :targets

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      if watchers.empty?
        watchers << ::Guard::Watcher.new(%r{^#{options[:from]}/.*$})
      else
        watchers.each { |w| normalize_watcher(w, options[:from]) }
      end
      @targets = Array(options[:to]).map { |to| Target.new(to, options) }
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      validate_presence_of(:from)
      validate_from_is_directory
      validate_presence_of(:to)
      validate_to_patterns_are_not_absolute
      validate_to_does_not_include_from
      resolve_targets
      validate_no_targets_are_files
      display_target_paths

      run_all if options[:run_at_start]
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
      run_on_changes(Watcher.match_files(self, Dir.glob("**/*.*")))
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_changes has failed
    def run_on_changes(paths)
      validate_at_least_one_target('copy')
      with_all_target_paths(paths) do |from_path, to_path|
        to_dir = File.dirname(to_path)
        if !File.directory?(to_dir) && options[:mkpath]
          UI.info("creating directory #{to_dir}") if options[:verbose]
          FileUtils.mkpath(to_dir)
        end
        validate_to_path(to_path)
        UI.info("copying to #{to_path}") if options[:verbose]
        FileUtils.cp(from_path, to_path)
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    def run_on_removals(paths)
      return unless options[:delete]
      validate_at_least_one_target('delete')
      with_all_target_paths(paths) do |_, to_path|
        validate_to_file(to_path)
        UI.info("deleting #{to_path}") if options[:verbose]
        FileUtils.rm(to_path)
      end
    end

    private

    def target_paths
      @targets.map { |t| t.paths }.flatten
    end

    def with_all_target_paths(paths)
      paths.each do |from_path|
        target_paths.each do |target_path|
          to_path = from_path.sub(@options[:from], target_path)
          yield(from_path, to_path)
        end
      end
    end

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

    def validate_presence_of(option)
      unless options[option]
        UI.error("Guard::Copy - :#{option} option is required")
        throw :task_has_failed
      end
    end

    def validate_from_is_directory
      path = options[:from]
      unless File.directory?(path)
        if File.file?(path)
          UI.error("Guard::Copy - '#{path}' is a file and must be a directory")
          throw :task_has_failed
        else
          UI.error("Guard::Copy - :from option does not contain a valid directory")
          throw :task_has_failed
        end
      end
    end

    def validate_to_does_not_include_from
      if options[:to].include?(options[:from])
        UI.error('Guard::Copy - :to must not include :from')
        throw :task_has_failed
      end
    end

    def validate_at_least_one_target(operation)
      if target_paths.empty?
        UI.error("Guard::Copy - cannot #{operation}, no valid :to directories")
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

    def validate_to_file(to_file)
      unless File.file?(to_file)
        UI.error('Guard::Copy - cannot delete, file does not exist:')
        UI.error("  #{to_file}")
        throw :task_has_failed
      end
    end

    def resolve_targets
      @targets.each do |target|
        unless target.resolve
          UI.warning("Guard::Copy - '#{target.pattern}' does not match a valid directory")
        end
      end
    end

    def validate_no_targets_are_files
      target_paths.each do |path|
        if File.file?(path)
          UI.error('Guard::Copy - :to option contains a file and must be all directories')
          throw :task_has_failed
        end
      end
    end

    def validate_to_patterns_are_not_absolute
      targets.each do |target|
        if target.absolute? && !options[:absolute]
          UI.error('Guard::Copy - :to contains an absolute path:')
          UI.error("  #{target.pattern}")
          UI.error('Set the :absolute option to allow absolute target paths')
          throw :task_has_failed
        end
      end
    end

    def display_target_paths
      if target_paths.any?
        UI.info("Guard::Copy - files in:")
        UI.info("  #{options[:from]}")
        UI.info("will be copied to#{ ' and removed from' if options[:delete] }:")
        target_paths.each { |target_path| UI.info("  #{target_path}") }
      end
    end

  end
end
