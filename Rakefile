require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = '--format progress'
end

desc 'run tests as appropriate for environment'
task :test => :spec do
  Rake::Task['cucumber'].invoke unless ENV['TRAVIS']
end

task :default => :test
