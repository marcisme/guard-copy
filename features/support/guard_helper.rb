require 'aruba/api'

module GuardHelper

  # Features sometimes hang when run in guard.
  # Unsure if this is FS event or IPC related; seeing if -i helps
  GUARD_CMD = 'guard start -i'
  POLL_INTERVAL = 0.1

  def start_guard(guardfile_contents)
    write_file('Guardfile', guardfile_contents)
    run_interactive(unescape(GUARD_CMD))
    sleep POLL_INTERVAL until output_from(GUARD_CMD).include?('Guard is now watching')
  end

  def verify_guard_behavior(max_tries = 20)
    # try increasing timeout for travis
    max_tries *= 5 if ENV['TRAVIS']
    tries = 0
    begin
      in_current_dir { yield }
    rescue => e
      if (tries += 1) < max_tries
        sleep POLL_INTERVAL
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
