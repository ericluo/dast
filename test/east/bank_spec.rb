require File.expand_path('../../spec_helper', __FILE__)

describe East::Bank do
  it "can be created with correct name" do
    bank = East::Bank.find(schema: 'hkyh')
    bank.must_be_instance_of(East::Bank)
  end

  it "raise ArgumentError if bank name incorrect" do
    proc { East::Bank.find(schema: 'hkh') }.must_raise ArgumentError
  end

  describe "when load data from directory" do
    before do
      @bank = East::Bank.find(schema: 'hkyh')
    end

    it "raise ArgumentError if date file is malformatted" do 
      skip
    end

  end
end
