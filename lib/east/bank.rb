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

    def self.find(license)
      config = BANKS.values.find{|h| h.has_value?(license)}
      Bank.new(BANKS.rassoc(config).first)
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
