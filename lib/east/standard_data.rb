# encoding: GBK

require 'open3'
require 'forwardable'

module East
  class StandardData
    # extend Forwardable
    IFN_REGEXP = /^(?<license>\w+)-(?<interface>\w+)-(?<gdate>\d+)\.txt$/ 

    def initialize(file)
      basename = File.basename(file)
      if fd = IFN_REGEXP.match(basename)
	@data_file = file
	@bank = Bank.find(license: fd[:license])
	@ifn = fd[:interface]
	@gdate = fd[:interface]
	@table = MAPPER[@ifn]
      else
	raise ArgumentError, "File: #{file} malformatted"
      end
    end

    # def_delegators :@data_file, :mtime
    
    def mdate
      File.new(@data_file).mtime.to_date
    end

    def logger
      @bank.logger
    end

    def command
      file_name = @data_file.to_s
      cmd = "db2 load from #{file_name} of del replace into #{@bank.schema}.#{@table}"
    end

    def load
      logger.info "LOADING: #{@data_file}"

      unless File.exists?(@data_file)
	logger.error "LOADED failed: #{@data_file} not existed"
      else
	$stdout.puts "LOADING: #{command}"
	exit_status = run(command)
	if exit_status.success?
	  logger.info "Loaded successfully"
	else
	  logger.warn "Loaded with warning or error: #{exit_status.inspect}"
	end
      end
    end

    def run(cmd)
      Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
	stdin.close

	while line = stdout_err.gets
	  $stdout.puts line
	  line = line.chomp
	  logger.info(line) if /行数/ =~ line
	end

	return wait_thr.value
      end
    end

  end
end
