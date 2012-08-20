require 'guard/copy/base_operation'

module Guard
  class Copy
    class CopyOperation < BaseOperation

      def with_target_path(from_path, to_path)
        validate_to_path_exists(to_path)
        copy(from_path, to_path)
      end

      private

      def validate_to_path_exists(to_path)
        to_dir = File.dirname(to_path)
        unless File.directory?(to_dir)
          UI.error('Guard::Copy - cannot copy, directory path does not exist:')
          UI.error("  #{to_dir}")
          throw :task_has_failed
        end
      end

      def copy(from_path, to_path)
        UI.info("copying to #{to_path}") if options[:verbose]
        FileUtils.cp(from_path, to_path)
      end

    end
  end
end

