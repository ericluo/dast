require 'rake/testtask'
require 'resque/tasks'


namespace :east do
  Rake::TestTask.new do |t|
    t.test_files = Dir['test/east/*_spec.rb']
  end

end

task :default => 'east:test'
