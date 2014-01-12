# encoding: UTF-8

require 'thor'
require 'east'

module East
  class CLI < Thor
    include Thor::Actions

    desc "generate_sql", "generate sql script for the given schema"
    option :schema, type: :string, required: true
    def generate_sql
      @schema = options[:schema]
      destination = East::ROOT.join("sql/#{@schema.downcase}")
      template "grant.sql.erb", destination.join("grant.sql")
      template "runstat.sql.erb", destination.join("runstat.sql")
    end

    desc "setup database", "setup database for given schema"
    option :schema, type: :string, required: true
    def setup
      schema = options[:schema]

      # invoke :generate_sql
      # create table
      # create_sql = East::ROOT.join("sql/create_table.sql")
      # create_log = East::ROOT.join("log/create_#{schema}.log")
      db_cmd(schema){run("db2 list tables")}
      # db_cmd(schema) {
      #   system("db2 select current schema from sysibm.sysdummy1")
      #   system("db2 -tvf #{create_sql} > #{create_log}")}


      # Grant rights
      # grant_sql = East::ROOT.join("sql/grant_#{schema}.sql").to_s
      # grant_log = East::ROOT.join("log/grant_#{schema}.log").to_s
      # db_cmd(schema) {system("db2 -tvf #{grant_sql} > #{grant_log}")}
    end

    option :glob, aliases: ['-g'], type: :string, default: '*.txt'
    desc "check DIR", "check whether the name of files in the given DIR is valid"
    def check(dir)
      DataLoader.new(dir, options[:glob]).check
    end

    desc "import DIR", "import data from the given directory"
    # option :synchronized, :aliases => ["-s"], :type => :boolean, :default => false
    option :glob,         :aliases => ['-g'], :type => :string,  :default => '*.txt'
    option :replace,      :aliases => ["-r"], :type => :boolean, :default => false
    option :after,        :aliases => [],     :type => :string
    def import(dir)
      opts = @options.symbolize_keys.slice(:replace, :after) if @options
      East::DataLoader.new(dir, options[:glob]).load(opts)
    end

  end
end

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
