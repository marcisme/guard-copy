require 'fakefs/spec_helpers'
require 'fileutils'

# monkey patch for now
FakeFS::FakeDir.class_eval do
  attr_accessor :mtime
end

module FileHelpers

  def file(f)
    FileUtils.touch(f)
  end

  def dir(d, mtime = nil)
    dir = FileUtils.mkpath(d)
    dir.mtime = Time.utc(mtime) if mtime
  end

  def path(p)
    dir(File.dirname(p))
    file(p)
  end

end

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.include FakeFS::SpecHelpers
  config.include FileHelpers
end
