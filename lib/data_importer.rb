# coding: GBK

require 'logger'
require 'open3'
require 'yaml'

module East
  class DataImporter
    FN_REGEXP = /^(\w+)-(\w+)-(\d+)$/ 
    MAPPER = YAML.load_file('../config/mapper.yaml')
    SCHEMA = 'HKYH'

    def initialize(options, files)
      @options = options
      @files = files

      @commands, @invalid, @unmapped = [], [], []
      check_files
      prepare
    end

    def prepare
      system("db2 connect to EASTST")
      system("db2 set current schema='HKYH'")
    end

    def check_files
      @files.each do |file|
	fn = File.basename(file, '.txt')
	if FN_REGEXP.match(fn)
	  license_num, ifn, gather_date = FN_REGEXP.match(fn).captures
	  if MAPPER[ifn]
	    @commands << "db2 load from #{file} of del replace into #{SCHEMA}.#{MAPPER[ifn]}"
	  else
	    @unmapped << file
	  end
	else
	  @invalid << file
	end
      end

      logger.info "Invalid interface file: #{@invalid.inspect}" unless @invalid.empty?
      logger.error "Unmapped interface file: #{@unmapped.inspect}" unless @unmapped.empty?
    end

    def process
      @commands.each do |cmd|
	logger.info "Load data with command: #{cmd}"
	Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
	  stdin.close

	  while line = stdout_err.gets
	    $stdout.puts line
	    line = line.chomp
	    logger.info(line) if /行数/ =~ line
	  end

	  exit_status = wait_thr.value
	  if exit_status.success?
	    logger.info exit_status.inspect
	  else
	    logger.warn exit_status.inspect
	  end

	  logger.flush
	end
      end
    end

    private
    def logger
      @logger ||= Logger.new('../log/east.log')
    end
  end
end

# vim:shiftwidth=2:softtabstop=2:
