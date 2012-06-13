require 'fakefs/spec_helpers'
require 'fileutils'
require 'guard/copy'

ENV['GUARD_ENV'] = 'test'

# monkey patch for now
FakeFS::FakeDir.class_eval do

  # we need to be able to set mtime for newest directory tests
  attr_accessor :mtime

  # fakefs returns full paths, which is inconsistent with real globs
  def to_s
    name
  end
end

module FileHelpers

  def file(f)
    dir(File.dirname(f))
    FileUtils.touch(f)
  end

  def dir(d, mtime = nil)
    dir = FileUtils.mkpath(d)
    dir.mtime = Time.utc(mtime) if mtime
  end

end

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include FileHelpers
end
