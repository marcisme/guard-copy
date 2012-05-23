require 'aruba/api'

module GuardHelper

  GUARD_CMD = 'guard start'

  def start_guard(guardfile_contents)
    write_file('Guardfile', guardfile_contents)
    run_interactive(unescape(GUARD_CMD))
    sleep 0.1 until output_from(GUARD_CMD).include?('Guard is now watching')
  end

  def verify_guard_behavior(max_tries = 10)
    # try increasing timeout for travis
    max_tries *= 5 if ENV['TRAVIS']
    tries = 0
    begin
      in_current_dir { yield }
    rescue => e
      if (tries += 1) < max_tries
        sleep 0.1
        retry
      else
        raise e
      end
    end
  end

  def guard_output
    output_from(GUARD_CMD)
  end

end

World(GuardHelper)
