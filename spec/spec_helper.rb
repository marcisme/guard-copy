require 'fakefs/spec_helpers'
require 'fileutils'
require 'guard/copy'

ENV['GUARD_ENV'] = 'test'

# monkey patch for now
FakeFS::FakeDir.class_eval do

  # we need to be able to set mtime for newest directory tests
  attr_accessor :mtime

end

module FileHelpers

  # convert the path to the fakefs path
  def ffs(path)
    File.join(File.expand_path(File.join('..', '..'), __FILE__), path)
  end

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
