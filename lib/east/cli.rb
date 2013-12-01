# encoding: UTF-8

require 'thor'
require 'erb'
require 'date'
require 'east'

module East
  class CLI < Thor
    include Thor::Actions

    method_option :recursive, type: :boolean, default: false, aliases: 'r'
    desc "check DIR", "check whether the name of files in the given DIR is valid"
    def check(dir)
      pattern = options[:recursive] ? "**/*.txt" : "*.txt"
      files = Dir[File.join(dir, pattern)]

      sds = files.map {|file| StandardData.new(file)}
      malformat = sds.reject(&:valid?)

      puts "*" * 70
      puts "文件总数: #{sds.size}"
      puts "文件名格式错误数: #{malformat.size}"
      puts "*" * 20 + "--格式错误文件列表--" + "*" * 20
      malformat.each {|mf| puts "  #{mf.file}"}
    end

    desc "generate_sql", "generate sql script for the given schema"
    method_option :schema, type: :string, required: true
    def generate_sql
      @schema = options[:schema]
      destination = East::ROOT.join("sql/#{@schema.downcase}")
      template "grant.sql.erb", destination.join("grant.sql")
      template "runstat.sql.erb", destination.join("runstat.sql")
    end

    desc "setup database", "setup database for given schema"
    method_option :schema, type: :string, required: true
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


      # grant rights
      # grant_sql = East::ROOT.join("sql/grant_#{schema}.sql").to_s
      # grant_log = East::ROOT.join("log/grant_#{schema}.log").to_s
      # db_cmd(schema) {system("db2 -tvf #{grant_sql} > #{grant_log}")}
    end

    desc "import DIR", "import data from the given directory"
    method_option :replace, type: :boolean, default: true
    method_option :schema, type: :string, required: true
    method_option :newer, type: :string
    def import(dir)
      schema = options[:schema]
      bank = East::Bank.find(schema: schema)

      invoke :connect

      if options[:newer]
        begin
          newer_than = Date.parse(options[:newer])
          bank.load_data(dir) do |sds|
            sds.select {|sd| sd.mdate > newer_than}
          end
        rescue
          raise "parse date failed"
        end
      else
        bank.load_data(dir)
      end
    end

    
    def self.source_root
      East::ROOT.join("template")
    end

    private

    def db_cmd(schema)
      run("db2 connect to sample user db2inst1 using db2inst1")
      run("db2 set current schema='#{schema}'")
      yield
    end

    def logger
      @logger ||= Logger.new('../log/east.log')
    end

  end
end

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
