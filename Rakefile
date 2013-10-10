require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)

desc 'run tests as appropriate for environment'
task :test => :spec do
  Rake::Task['cucumber'].invoke
end

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = '--format progress'
end

task :default => :test
