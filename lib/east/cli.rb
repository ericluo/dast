# encoding: UTF-8

require 'thor'
require 'east'

module East
  class CLI < Thor
    include Thor::Actions

    desc "generate", "generate sql script"
    option :schemas, type: :string, required: true, default: :all
    option :username, type: :string, default: "db2inst1"
    option :password, type: :string, default: "db2inst1"
    def generate
      @username = options[:username]
      @password = options[:password]
      ["create_eastst.sql.erb"].each do |file|
        dest = File.basename(file).sub(/\.erb$/, '')
        template file, East::ROOT.join("sql", dest)
      end
      
      schemas(options).each do |schema|
        @schema = schema

        ["create_table.sql.erb", "grant.sql.erb", "runstat.sql.erb"].each do |file|
          dest = File.basename(file).sub(/\.erb$/, '')
          template file, East::ROOT.join("sql", @schema.downcase, dest)
        end
      end
    end

    desc "create DATABASE DIR", "create database on the given path"
    def create(dbname, dir)
      # create database 
      run "db2 create database #{dbname} automatic storage yes on #{dir} using codeset gbk territory cn"
      # add user for database
      run "sudo useradd -g db2iadm1 #{dbname}"
      # create database eastst
      run "db2 -tvf sql/create_eastst.sql > log/create_eastst.log"
    end

    desc "setup", "setup database and dbuser for given schemas"
    option :schemas, type: :string, default: :all
    def setup
      schemas(options).each do |schema|
        schema = schema.downcase

        # create table for schema
        run "db2 -tvf sql/#{schema}/create_table.sql > log/create_table_#{schema}.log"
        # grant rights to user
        run "db2 -tvf sql/#{schema}/grant.sql > log/grant_#{schema}.log"
        # create user for schema
        # run "sudo useradd #{schema}"
        # run "sudo passwd #{schema}"
      end
    end

    desc "check DIR", "check whether the name of files in the given DIR is valid"
    option :glob, aliases: ['-g'], type: :string, default: '*.txt'
    def check(dir)
      DataLoader.new(dir, options[:glob]).check
    end

    desc "import DIR", "import data from the given directory"
    option :synchronized, :aliases => ["-s"], :type => :boolean, :default => true
    option :glob,         :aliases => ['-g'], :type => :string,  :default => '*.txt'
    option :replace,      :aliases => ["-r"], :type => :boolean, :default => false
    option :after,        :aliases => [],     :type => :string
    def import(dir)
      opts = @options.symbolize_keys.slice(:replace, :after) if @options
      sds = East::DataLoader.new(dir, options[:glob]).sds
      run "db2 connect to eastst user db2inst1 using db2inst1"
      sds.each do |sd|
        run sd.command
      end
    end

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
