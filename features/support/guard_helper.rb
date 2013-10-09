require 'aruba/api'

module GuardHelper

  # The following options seem to be required for things to work reliably:
  #   -i interactive mode doesn't work at all; nothing ever gets copied
  #   -p polling is the only mode that doesn't sometimes timeout
  GUARD_CMD = 'guard start -i -p'
  POLL_INTERVAL = 0.1
  DEFAULT_WAIT_SECONDS = 2

  def start_guard(guardfile_contents)
    # clear out the default ignores to remove 'tmp', which is where our tests run
    write_file('Guardfile', "ignore! []\n")
    append_to_file('Guardfile', guardfile_contents)
    run_interactive(unescape(GUARD_CMD))
    verify_guard_behavior { guard_output.should include('Guard is now watching') }
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
