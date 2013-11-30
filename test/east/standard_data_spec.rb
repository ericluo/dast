require File.expand_path("../../spec_helper", __FILE__)

describe East::StandardData do
  before do
    @bad_file_name = 'B0187H242010002-ZZKJQKMB.txt'
    @good_file_name = 'B0187H242010002-ZZKJQKMB-20130930.txt'
  end

  it "should be invalid when initialized with wrong file" do
    sd = East::StandardData.new(@bad_file_name) 
    sd.wont_be :valid?
  end

  it "can be created with correct file name" do
    sd = East::StandardData.new(@good_file_name)
    sd.must_be :valid?   
  end


end
