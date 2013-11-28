# encoding: UTF-8

require 'thor'
require 'erb'
require 'date'
require 'east'

module East
  class CLI < Thor
    include Thor::Actions

    desc "check FILES", "check gathered data's filename with naming criteria"
    def check(*files)
      results = check_files(files)

      puts "*" * 70
      puts "正常文件数: #{results[:ok].size}"
      puts "格式错误文件数: #{results[:invalid].size}"
      puts "未映射文件数: #{results[:unmapped].size}" 
    end

    desc "generate sql script", "generate sql script for the given schema"
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

    def normalize_files(files)
      norm_files = []

      if files.empty?
        norm_files = Dir[File.join(Dir.pwd, "*.txt")]
      else
        files.each do |path|
          if File.directory?(path)
            norm_files += Dir[File.join(path, "*.txt")]
          else
            norm_files << path
          end
        end
      end

      norm_files.map{|f| Pathname.new(f).realpath}
    end

    def check_files(files)
      files = normalize_files(files)
      results = Hash.new {|hash, key| hash[key] = []}
      files.each do |file|
        if FN_REGEXP =~ file.basename('.txt').to_s
          (map_table(file) ? results[:ok] : results[:unmapped]) << file
        else
          results[:invalid] << file
        end
      end

      results
    end

    # file: pathname
    def map_table(file)
      mdata = FN_REGEXP.match(file.basename('.txt').to_s)
      interface_name = mdata[:interface_name]
      MAPPER[interface_name]
    end

    def file_name(license_number, ifn, gather_date)
      "#{license_number}-#{ifn}-#{gather_date}"
    end

    def logger
      @logger ||= Logger.new('../log/east.log')
    end

  end
end

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
