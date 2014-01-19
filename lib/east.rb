# encoding: GBK

require 'bundler/setup'

require 'pry'
require 'active_support'
require 'active_support/core_ext/hash'

require 'pathname'
require 'open3'
require 'thor'
require 'logger'
require 'yaml'

require 'east/bank'
require 'east/standard_data'
require 'east/db_action'
require 'east/data_loader'

module East

  ROOT   = Pathname.new(File.join(File.dirname(__FILE__),'..')).expand_path
  MAPPER = ::YAML.load_file(ROOT.join('config/mapper.yaml'))
  BANKS  = ::YAML.load_file(ROOT.join('config/banks.yaml'))

end
