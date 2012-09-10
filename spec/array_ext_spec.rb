require 'spec_helper'
require 'activerecord-postgres-array/array'

describe "Array" do
  describe "#to_postgres_array" do
    it "returns '{}' if used on an empty array" do
      [].to_postgres_array.should == "'{}'"
    end

    it "returns a correct array if used on a numerical array" do
      [1,2,3].to_postgres_array.should == "'{1,2,3}'"
    end

    it "returns a correct array if used on a float array" do
      [1.0,2.1,3.2].to_postgres_array.should == "'{1.0,2.1,3.2}'"
    end

    it "returns a correct array if used on a string array" do
      ["Ruby","on","Rails"].to_postgres_array.should == "'{\"Ruby\",\"on\",\"Rails\"}'"
    end

    it "escapes double quotes correctly" do
      ["Ruby","on","Ra\"ils"].to_postgres_array.should == "'{\"Ruby\",\"on\",\"Ra\\\"ils\"}'"
    end

    it "escapes backslashes correctly" do
      ["\\","\""].to_postgres_array.should == '\'{"\\\\","\\""}\''
    end
  end
end