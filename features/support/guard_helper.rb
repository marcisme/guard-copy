require 'aruba/api'

module GuardHelper

  # TODO: Features sometimes hang when run in guard.
  #       Unsure if this is FS event or IPC related; seeing if -i helps
  # TODO: Guard 1.1 only works in tests with polling (-p), but it works
  #       fine in manual testing. It seems that file system
  #       notifications do not get triggered or delivered to the guard
  #       process when run via Cucumber/Aruba.
  GUARD_CMD = 'guard start -i -p'
  POLL_INTERVAL = 0.1
  DEFAULT_WAIT_SECONDS = 2

  def start_guard(guardfile_contents)
    write_file('Guardfile', guardfile_contents)
    run_interactive(unescape(GUARD_CMD))
    sleep POLL_INTERVAL until guard_output.include?('Guard is now watching')
  end

  def verify_guard_behavior(seconds = DEFAULT_WAIT_SECONDS)
    start_time = Time.now

    begin
      in_current_dir { yield }
    rescue => e
      raise e if (Time.new - start_time) >= seconds
      sleep POLL_INTERVAL
      retry
    end
  end

  def guard_output
    output_from(GUARD_CMD)
  end

end

World(GuardHelper)
