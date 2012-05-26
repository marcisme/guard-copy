require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'run tests as appropriate for environment'
task :test => :spec do
  Rake::Task['cucumber'].invoke unless ENV['TRAVIS']
end

unless ENV['TRAVIS']
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = '--format progress'
  end
end

task :default => :test
