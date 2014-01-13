# -*- coding: utf-8 -*-
module East
  class DataLoader
    attr_accessor :sds          # all standard data files

    def initialize(dir, glob)
      files = Dir[File.join(dir, glob)]
      @sds = files.map {|file| StandardData.new(file)}
    end
    
    def check
      malformat = @sds.reject(&:valid?)

      puts "*" * 70
      puts "文件总数: #{@sds.size}"
      puts "文件名格式错误数: #{malformat.size}"
      puts "*" * 20 + "--格式错误文件列表--" + "*" * 20
      malformat.each {|mf| puts "  #{mf.file}"}
    end

    # options
    #   :after
    #   :replace
    def load(options)
      # if options[:after]
      #   after_filter = lambda {|sd| sd.mdate > Date.parse(options[:after])}
      #   @sds = @sds.select(&after_filter)
      # end
      @sds.map(&:async_load)
    end

  end
end

    
