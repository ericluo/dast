require File.expand_path('../../spec_helper', __FILE__)

describe East::DB do

  include East::DB

  it "run script on the given db and schema" do
    status = db_pipe_cmd("sample", "db2inst1", user: "db2inst1", passwd: "db2inst1") do
      "list tables"
    end
    status.must_be :success?
  end

end
