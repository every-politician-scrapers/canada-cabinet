# frozen_string_literal: true

require 'rake/testtask'
require 'reek/rake/task'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_{spec,test}.rb']
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

task default: %i[test rubocop]
