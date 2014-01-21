# encoding: GBK

# require 'open3'
require 'resque'
require 'resque-history'

module East
  class StandardData
    # extend Forwardable
    IFN_REGEXP = /^(?<license>\w+)-(?<interface>\w+)-(?<gdate>\d+)$/ 
    attr_reader :file, :license, :interface, :gdate

    extend Resque::Plugins::History
    @queue = :data_loader

    def initialize(file)
      @file = file
      @license, @interface, @gdate = basename.scan /\w+/
    end

    def basename ; File.basename(@file, File.extname(@file)); end
    
    def bank ; Bank.find(@license); end
    
    def valid? ; pattern_valid? && license_valid? && interface_valid? ; end

    def pattern_valid? ; IFN_REGEXP =~ basename; end

    def license_valid? ; !bank.nil?; end

    def interface_valid? ; MAPPER.has_key?(@interface); end
    
    def mdate ; File.new(@file).mtime.to_date; end

    def logger; bank.logger; end

    def cmds
      "db2 load from #{@file} of del replace into #{bank.schema}.#{MAPPER[@interface]}"
    end

    def async_load
      Resque.enqueue(self.class, @file)
    end

    def load
      system "db2 connect to eastst user db2inst1 using db2inst1"
      system cmds
      # IO.popen("db2", 'w') do |io|
      #   io.puts "connect to eastst user db2inst1 using db2inst1"
      #   io.puts cmds
      # end
    end

    def perform
      load
    end

    def self.perform(file)
      sd = new(file)
      sd.perform
    end
  end
end
