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

  gem.add_dependency 'guard', '~> 1.0'

  gem.add_development_dependency 'bundler', '>= 1.1.0'
  gem.add_development_dependency 'rake', '>= 0.9.2'
  gem.add_development_dependency 'aruba', '~> 0.4'
  gem.add_development_dependency 'guard-cucumber', '>= 0.8'
  gem.add_development_dependency 'guard-rspec', '>= 0.7.2'
  gem.add_development_dependency 'fakefs', '>= 0.4.0'
  gem.add_development_dependency 'mocha', '>= 0.11.4'

  gem.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  gem.require_path  = 'lib'
end
