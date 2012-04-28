require "bundler/gem_tasks"

[:build, :install, :release].each do |task_name|
  Rake::Task[task_name].prerequisites << :spec
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

task :default => :spec
