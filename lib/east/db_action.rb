# encoding: utf-8

module East
  module DB

    def db_cmd(schema)
      system("db2 connect to eastst")
      system("db2 set current schema=#{schema}")
      yield if block_given?
    end
    
  end

end
