# encoding: GBK

require 'open3'
require 'forwardable'

module East
  class StandardData
    # extend Forwardable
    IFN_REGEXP = /^(?<license>\w+)-(?<interface>\w+)-(?<gdate>\d+)\.txt$/ 
    attr_reader :file, :license, :interface, :gdate

    def initialize(file)
      @file = file
      @license, @interface, @gdate = @file.scan /\w+/
    end

    def valid?
      pattern_valid? && license_valid? && interface_valid?
    end

    def pattern_valid?
      IFN_REGEXP =~ @file
    end

    def license_valid?
      Bank.find(@license)
    end

    def interface_valid?
      MAPPER.has_key?(@interface)
    end
    
    def mdate
      File.new(@file).mtime.to_date
    end

    def logger
      @bank.logger
    end

    def command
      cmd = "db2 load from #{file} of del replace into #{@bank.schema}.#{MAPPER[@interface]}"
    end

    def load
      logger.info "LOADING: #{@file}"

      unless File.exists?(@file)
	logger.error "LOADED failed: #{@file} not existed"
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
