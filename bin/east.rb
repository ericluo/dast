$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'east/cli'

East::CLI.start
