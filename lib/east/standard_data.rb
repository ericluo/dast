# encoding: GBK

require 'open3'
require 'forwardable'
require 'resque'

module East
  class StandardData
    # extend Forwardable
    IFN_REGEXP = /^(?<license>\w+)-(?<interface>\w+)-(?<gdate>\d+)$/ 
    attr_reader :file, :license, :interface, :gdate

    @queue = :data_loader

    def initialize(file)
      @file = file
      @license, @interface, @gdate = basename.scan /\w+/
    end

    def basename
      File.basename(@file, File.extname(@file))
    end
    
    def bank
      Bank.find(@license)
    end
    
    def valid?
      pattern_valid? && license_valid? && interface_valid?
    end

    def pattern_valid?
      IFN_REGEXP =~ basename
    end

    def license_valid?
      !bank.nil?
    end

    def interface_valid?
      MAPPER.has_key?(@interface)
    end
    
    def mdate
      File.new(@file).mtime.to_date
    end

    def logger
      bank.logger
    end

    def command
      cmd = "db2 load from #{@file} of del replace into #{bank.schema}.#{MAPPER[@interface]}"
    end

    def async_load
      Resque.enqueue(self.class, @file)
    end

    def perform
      db_cmd("eastst", bank.schema) do
        system(command)
      end
    end

    def self.perform(file)
      sd = new(file)
      sd.perform
    end
  end
end
