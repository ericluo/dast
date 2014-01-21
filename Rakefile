require 'rake/testtask'
require 'resque/tasks'


namespace :east do
  Rake::TestTask.new do |t|
    t.test_files = Dir['test/east/*_spec.rb']
  end

end

task "resque:setup" do
  ENV['QUEUE'] = 'data_loader'
  ENV['COUNT'] = '2'
  $:.unshift(File.join(File.dirname(__FILE__), "lib"))
  require 'east'
end

task :default => 'east:test'
