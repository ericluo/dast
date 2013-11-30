require File.expand_path('../../spec_helper', __FILE__)

describe East::Bank do

  describe "when be found by license" do
    it "can be found with corrent license" do
      bank = East::Bank.find('B0187H242010002')
      bank.must_be_instance_of(East::Bank)
    end

    it "nil should be returned with wrong license" do
      bank = East::Bank.find('B0187')
      bank.must_be_nil
    end
    
  end
  
end
