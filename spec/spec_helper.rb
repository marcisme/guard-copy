require 'fakefs/spec_helpers'
require 'fileutils'

module FileHelpers

  def file(f)
    FileUtils.touch(f)
  end

  def dir(d)
    FileUtils.mkpath(d)
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
