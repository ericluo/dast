require 'rake/testtask'

require 'resque/tasks'

Rake::TestTask.new do |t|
  t.test_files = Dir['test/east/*_spec.rb']
end

task :default => :test
