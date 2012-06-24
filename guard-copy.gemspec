# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/copy/version'

Gem::Specification.new do |gem|
  gem.name          = 'guard-copy'
  gem.version       = Guard::CopyVersion::VERSION
  gem.authors       = ['Marc Schwieterman']
  gem.email         = ['marc.schwieterman@gmail.com']
  gem.homepage      = 'https://github.com/marcisme/guard-copy'
  gem.summary       = 'Guard gem for copy'
  gem.description   = 'Guard::Copy automatically copies files.'

  gem.add_dependency 'guard', '~> 1.1.1'

  gem.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  gem.require_path  = 'lib'
end
