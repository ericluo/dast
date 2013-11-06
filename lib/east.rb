# encoding: GBK

require 'pathname'
require 'open3'
require 'logger'
require 'yaml'

require 'east/bank'
require 'east/standard_data'

module East

  ROOT   = Pathname.new(File.join(File.dirname(__FILE__),'..')).expand_path
  MAPPER = ::YAML.load_file(ROOT.join('config/mapper.yaml'))
  BANKS  = ::YAML.load_file(ROOT.join('config/banks.yaml'))

end
