require 'guard'
require 'guard/guard'
require 'fileutils'

module Guard
  class Copy < Guard

    # TODO: starting to move some of the option related behavior into separate classes.
    #       we probably need to separate validation that pertains to a valid configuration
    #       and validation that is about the file system state at runtime
    # TODO: think more about how to manage inter-option dependencies
    class FromOption

      COPY_FROM_PROJECT_ROOT_MAGIC_STRING = '.'

      attr_reader :path

      def initialize(path)
        @path = path
      end

      def validate_is_directory!
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

      def substitute_target_path(from_path, target_path)
        if path == COPY_FROM_PROJECT_ROOT_MAGIC_STRING
          target_path
        else
          from_path.sub(path, target_path)
        end
      end

      def default_watcher
        # sniff sniff
        if path == COPY_FROM_PROJECT_ROOT_MAGIC_STRING
          ::Guard::Watcher.new(%r{^.*$})
        else
          ::Guard::Watcher.new(%r{^#{path}/.*$})
        end
      end

    end

    autoload :Target, 'guard/copy/target'

    attr_reader :targets

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super
      @from = FromOption.new(options[:from])
      if watchers.empty?
        watchers << from.default_watcher
      else
        watchers.each { |w| normalize_watcher(w) }
      end
      @targets = Array(options[:to]).map { |to| Target.new(to, options) }
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      # TODO: This :from validation should probably go in the FromOption class,
      #       but then we have to do something with the :to validation...
      validate_presence_of(:from)
      from.validate_is_directory!
      validate_presence_of(:to)
      validate_to_patterns_are_not_absolute
      validate_to_does_not_start_with_from
      resolve_targets!
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
        copy(from_path, to_path)
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

    attr_reader :from

    def target_paths
      @targets.map { |t| t.paths }.flatten
    end

    def with_all_target_paths(paths)
      paths.each do |from_path|
        target_paths.each do |target_path|
          to_path = from.substitute_target_path(from_path, target_path)
          yield(from_path, to_path)
        end
      end
    end

    def normalize_watcher(watcher)
      unless watcher.pattern.source =~ %r{^\^#{from.path}/.*}
        normalized_source = watcher.pattern.source.sub(%r{^\^?(#{from.path})?/?}, "^#{from.path}/")
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

    def validate_to_does_not_start_with_from
      if Array(options[:to]).any? { |to| to.start_with?(from.path) }
        UI.error('Guard::Copy - :to must not start with :from')
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

    def resolve_targets!
      @targets.each { |target| target.resolve! }
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
        UI.info("  #{from.path}")
        UI.info("will be copied to#{ ' and removed from' if options[:delete] }:")
        target_paths.each { |target_path| UI.info("  #{target_path}") }
      end
    end

    def copy(from_path, to_path)
      begin
        FileUtils.cp(from_path, to_path)
      rescue Errno::EISDIR
        UI.warning("matched path is a directory; skipping")
        UI.warning("  #{ from_path }")
      end
    end

  end
end
