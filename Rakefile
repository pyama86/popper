require "bundler/gem_tasks"
require "rspec/core/rake_task"

ENV['POPPER_TEST'] = "1"
RSpec::Core::RakeTask.new("spec")
task :default => :spec

