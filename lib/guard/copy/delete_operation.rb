require 'guard/copy/base_operation'

module Guard
  class Copy
    class DeleteOperation < BaseOperation

      def with_target_path(from_path, to_path)
        validate_to_file_exists(to_path)
        remove(to_path)
      end

      private

      def validate_to_file_exists(to_file)
        unless File.file?(to_file)
          UI.error('Guard::Copy - cannot delete, file does not exist:')
          UI.error("  #{to_file}")
          throw :task_has_failed
        end
      end

      def remove(to_path)
        UI.info("deleting #{to_path}") if options[:verbose]
        FileUtils.rm(to_path)
      end

    end
  end
end

