# encoding: GBK

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'thor'
require 'east'

module East
  class Data < Thor
    FN_REGEXP = /^(?<license_num>\w+)-(?<interface_name>\w+)-(?<gather_data>\d+)$/ 

    desc "check FILES", "check gathered data's filename with naming criteria"
    def check(*files)
      results = check_files(files)

      puts "*" * 70
      puts "正常文件数: #{results[:ok].size}"
      puts "格式错误文件数: #{results[:invalid].size}"
      puts "未映射文件数: #{results[:unmapped].size}" 
    end

    desc "import BANK at specific DIR and DATE", "import gathered data files to db"
    def import(bank, dir, date)
      p bank.to_sym
      b = ::East::BANKS[bank.to_sym]
      b.load_data(dir, date)
    end

    private
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

East::Data.start(ARGV)

# vim:shiftwidth=2:softtabstop=2:filetype=ruby:
