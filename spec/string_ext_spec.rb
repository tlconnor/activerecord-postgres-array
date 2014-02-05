require 'spec_helper'
require 'activerecord-postgres-array/string'

describe "String" do
  describe "#valid_postgres_array?" do
    it 'returns true for an empty string' do
      "".should be_valid_postgres_array
    end

    it 'returns true for a string consisting only of whitespace' do
      "   ".should be_valid_postgres_array
    end

    it 'returns true for a valid postgres integer array' do
      "{10000, 10000, 10000, 10000}".should be_valid_postgres_array
    end

    it 'returns true for a valid postgres float array' do
      "{10000.2, .5, 10000, 10000.9}".should be_valid_postgres_array
    end

    it 'returns true for a valid postgres numerical array with irregular whitespace' do
      "{   10000,   10000  ,  10000,10000}".should be_valid_postgres_array
    end

    it 'returns false for an array with invalid commas' do
      "{213,}".should_not be_valid_postgres_array
    end

    it 'allows enclosing single quotes' do
      '\'{"ruby", "on", "rails"}\''.should be_valid_postgres_array
    end

    it 'returns false for an array without enclosing curly brackets' do
      "213, 1234".should_not be_valid_postgres_array
    end

    it 'returns true for a valid postgres string array' do
      '{"ruby", "on", "rails"}'.should be_valid_postgres_array
    end

    it 'returns true for a postgres string array with escaped double quote' do
      '{"ruby", "on", "ra\"ils"}'.should be_valid_postgres_array
    end

    it 'returns false for a postgres string array with wrong quotation' do
      '{"ruby", "on", "ra"ils"}'.should_not be_valid_postgres_array
    end

    it 'returns true for string array without quotes' do
      "{ruby, on, rails}".should be_valid_postgres_array
    end

    it 'returns false for array consisting of commas' do
      "{,,}".should_not be_valid_postgres_array
    end

    it 'returns false for concatenated strings' do
      '{"ruby""on""rails"}'.should_not be_valid_postgres_array
    end

    it "returns false if single quotes are not closed" do
      '\'{"ruby", "on", "rails"}'.should_not be_valid_postgres_array
    end

    it "returns true for an empty postgres array" do
      "{}".should be_valid_postgres_array
    end

    it "returns false for postgres array beginning with ," do
      "{,ruby,on,rails}".should_not be_valid_postgres_array
    end

  end

  describe "#from_postgres_array" do
    it 'returns an empty array if string is empty' do
      "".from_postgres_array.should == []
    end

    it 'returns an empty array if empty postgres array is given' do
      "{}".from_postgres_array.should == []
    end

    it 'returns an correct array if a valid postgres array is given' do
      "{Ruby,on,Rails}".from_postgres_array.should == ["Ruby", "on", "Rails"]
    end

    it 'correctly handles commas' do
      '{Ruby,on,"Rails,"}'.from_postgres_array.should == ["Ruby", "on", "Rails,"]
    end

    it 'correctly handles single quotes' do
      "{Ruby,on,Ra'ils}".from_postgres_array.should == ["Ruby", "on", "Ra'ils"]
    end

    it 'correctly handles double quotes' do
      "{Ruby,on,\"Ra\\\"ils\"}".from_postgres_array.should == ["Ruby", "on", 'Ra"ils']
    end

    it 'correctly handles backslashes' do
      '\'{"\\\\","\\""}\''.from_postgres_array.should == ["\\","\""]
    end

    it 'correctly handles multi line content' do
      "{A\nB\nC,X\r\nY\r\nZ}".from_postgres_array.should == ["A\nB\nC", "X\r\nY\r\nZ"]
    end

    it "returns NULL values as nil" do
      "{NULL,on,Rails}".from_postgres_array.should == [nil, "on", "Rails"]
    end

    context "with a base_type of :decimal" do
      it "returns decimal numbers" do
        "{1.1,2.1,3.1}".from_postgres_array(:decimal).should eql [1.1,2.1,3.1]
      end

      it "returns NULL values as nil" do
        "{NULL,2.1,3.1}".from_postgres_array(:decimal).should eql [nil, 2.1, 3.1]
      end
    end

    context "with a base_type of :integer" do
      it "returns integers" do
        "{1,2,3}".from_postgres_array(:integer).should eql [1,2,3]
      end

      it "returns NULL values as nil" do
        "{NULL,2,3}".from_postgres_array(:integer).should eql [nil, 2, 3]
      end
    end

    context "with a base_type of :float" do
      it "returns floats" do
        "{1,2,3}".from_postgres_array(:float).should eql [1.to_f,2.to_f,3.to_f]
      end

      it "returns NULL values as nil" do
        "{NULL,2,3}".from_postgres_array(:float).should eql [nil, 2.to_f, 3.to_f]
      end
    end

    context "with a base_type of timestamp" do
      it "returns time objects" do
        '{"2004-10-19 10:23:54","2004-10-19 10:23:54"}'.from_postgres_array(:timestamp).should eql [
          "2004-10-19 10:23:54".to_time,
          "2004-10-19 10:23:54".to_time 
        ]
      end

      it "returns NULL values as nil" do
        '{NULL,"2004-10-19 10:23:54"}'.from_postgres_array(:timestamp).should eql [
          nil, "2004-10-19 10:23:54".to_time 
        ]
      end
    end
  end
end
