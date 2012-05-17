require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.include FakeFS::SpecHelpers
end
