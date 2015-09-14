require "bundler/gem_tasks"
require "rspec/core/rake_task"

ENV['CODECLIMATE_REPO_TOKEN']="a2b80ce9c5697fcb0f3dfcba23d9148a603156ec164993d29233ecadd45506e8"
ENV['POPPER_TEST'] = "1"
RSpec::Core::RakeTask.new("spec")
task :default => :spec

