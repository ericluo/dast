# encoding: UTF-8

require 'thor'
require 'east'

module East
  class CLI < Thor
    include Thor::Actions

    desc "generate_sql", "generate sql script"
    method_option :schemas, type: :string, required: true, default: :all
    def generate_sql
      ["create_eastst.sql", "create_table.sql"].each do |file|
        copy_file East::ROOT.join("template/#{file}"),
                  East::ROOT.join("sql/#{file}")
      end
      
      schemas = if options[:schemas] == :all
                  East::BANKS.collect{|_,v| v["schema"]}
                else
                  options[:schemas].split(',')
                end
      schemas.each do |schema|
        @schema = schema
        destination = East::ROOT.join("sql/#{@schema.downcase}")
        template "grant.sql.erb", destination.join("grant.sql")
        template "runstat.sql.erb", destination.join("runstat.sql")
      end
    end

    desc "init database", "init eastst databse"
    def init_db
      # create database eastst
      run "db2 -tvf sql/create_eastst.sql > log/create_eastst.log"
      # create and use schema
      run "db2 set current schema=#{schema}"
      # create table for schema
      run "db2 -tvf sql/create_table.sql > log/create_table.log"
      # grant rights to user
      run "db2 -tvf sql/grant.sql > log/grant.log"
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

    private
    # used by thor to find the template
    def self.source_root
      East::ROOT.join("template")
    end
  end
end

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
