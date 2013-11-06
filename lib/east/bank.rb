require 'logger'
require 'pathname'

module East
  class Bank
    attr_reader :schema, :license, :logger

    def initialize(name)
      config = BANKS[name]
      raise ArgumentError, "No Bank with name: #{name}" unless config

      @schema = config["schema"]
      @license = config["license"]
      @logger ||= Logger.new(ROOT.join("log/east_#{@schema}.log"))
    end

    def self.find(schema: nil, license: nil)
      raise ArgumentError, "Arguments are all nil." unless schema || license
      
      config = if schema
	BANKS.find {|k, v| v["schema"] == schema}
      else
	BANKS.find {|k, v| v["license"] == license}
      end
      raise ArgumentError, "Bank(schema: '#{schema}', license: '#{license}') not found" unless config
      Bank.new(config[0])
    end

    def load_data(dir, includes: nil)
      sds = []
      files = File.join(dir, "*.txt")
      Dir.glob(files).each do |file|
	begin
	  sds << StandardData.new(file)
	rescue ArgumentError
	  logger.warn "File #{file} malformatted."
	end
      end

      sds = yield(sds) if block_given?
      db_action {sds.map(&:load) }
    end

    def generate_command(dir, gather_date)
      MAPPER.each do |ifn, table|
	data_file = Pathname.new(dir).join("#{@license_number}-#{ifn}-#{gather_date}.txt")
	sd = StandardData.new(self, data_file, ifn)
	$stdout.puts sd.command
      end
    end

    def db_action
      system("db2 connect to EASTST")
      system("db2 set current schema='#{@schema}'")
      yield
    end
  end
end
