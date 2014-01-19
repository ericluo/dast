# encoding: utf-8

require 'resque'

module DB2Jobs
  @queue = :db_action

  def self.perform(opts, cmds)
    IO.popen("db2", 'w') do |io|
      io.puts "connect to #{opts["database"]} user #{opts["user"]} using #{opts["passwd"]}"
      io.puts cmds
    end
  end
end
