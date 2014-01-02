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
      @logger ||= Logger.new(ROOT.join("log/east.log"))
    end

    def self.find(license)
      BANKS.each_pair do |k, v|
        return Bank.new(k) if v.has_value?(license)
        next
      end
      nil
    end
    
    def load_data(dir, includes: nil, &filter)
      sds = []
      files = File.join(dir, "*.txt")
      Dir.glob(files).each do |file|
	begin
	  sds << StandardData.new(file)
	rescue ArgumentError
	  logger.warn "File #{file} malformatted."
	end
      end

      sds = filter.call(sds) unless filter
      sds.map(&:load)
    end

    def generate_command(dir, gather_date)
      MAPPER.each do |ifn, table|
	data_file = Pathname.new(dir).join("#{@license_number}-#{ifn}-#{gather_date}.txt")
	sd = StandardData.new(self, data_file, ifn)
	$stdout.puts sd.command
      end
    end

  end
end
