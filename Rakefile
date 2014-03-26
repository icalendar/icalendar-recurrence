require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'test/**/test*.rb'
  t.verbose = true
end

task default: [:test, :build]