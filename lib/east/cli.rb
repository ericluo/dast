# encoding: UTF-8

require 'east'
require 'resque'

module East
  class CLI < Thor
    include Thor::Actions

    desc "query", "query database info"
    option :database, :type => :string, :default => "sample"
    option :user,     :type => :string, :default => "db2inst1"
    option :passwd,   :type => :string, :default => "db2inst1"
    def query
      Resque.enqueue DB2Jobs, options, <<-SQL
        select * from syscat.tables
        terminate
      SQL
    end
    
    desc "generate_sql", "generate sql script"
    option :schemas, type: :string, required: true, default: :all
    def generate_sql
      ["create_eastst.sql", "create_table.sql"].each do |file|
        copy_file East::ROOT.join("template/#{file}"),
                  East::ROOT.join("sql/#{file}")
      end
      
      schemas(options).each do |schema|
        @schema = schema
        destination = East::ROOT.join("sql/#{@schema.downcase}")
        template "grant.sql.erb", destination.join("grant.sql")
        template "runstat.sql.erb", destination.join("runstat.sql")
      end
    end

    desc "init_db", "init eastst databse"
    option :schemas, type: :string, required: true, default: :all
    def init_db
      # connec to database
      as_user("db2inst1") do
        run "db2 connect to eastst user db2inst1 using db2inst1"
      end
      # create database eastst
      # run "db2 -tvf sql/create_eastst.sql > log/create_eastst.log"

      # schemas(options).each do |schema|
      #   # create and use schema
      #   system "db2 set current schema=#{schema}"
      #   # create table for schema
      #   system "db2 -tvf sql/create_table.sql > log/create_table_#{schema}.log"
      #   # grant rights to user
      #   system "db2 -tvf sql/#{schema}/grant.sql > log/grant_#{schema}.log"
      # end
    end

    desc "setup", "setup database for given schema"
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

    # public methods but not commands
    no_commands {

    }

    private
    # used by thor to find the template
    def self.source_root
      East::ROOT.join("template")
    end

    def schemas(options)
      if options[:schemas] == :all
        East::BANKS.collect{|_,v| v["schema"]}
      else
        options[:schemas].split(',') || []
      end
    end

    require 'etc'
    def as_user(user, &block)
      u = Etc.getpwnam(user)
      Process.fork do
        Process.uid = u.uid
        block.call
      end
    end

  end
end

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
