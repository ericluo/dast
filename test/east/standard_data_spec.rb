require File.expand_path("../../spec_helper", __FILE__)

describe East::StandardData do
  before do
    @bad_file_name = 'B0187H242010002-ZZHJQKMB.txt'
    @good_file_name = 'B0187H242010002-ZZHJQKMB-20130930.txt'
  end

  it "raise ArgumentError when initialized with wrong file" do
    proc { East::StandardData.new(@bad_file_name)}.must_raise ArgumentError
  end

  it "can be created with correct file name" do
    sd = East::StandardData.new(@good_file_name)
    sd.wont_be_nil
  end


end
