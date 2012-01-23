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

    it 'returns false for an array without enclosing curly brackets' do
      "213, 1234".should_not be_valid_postgres_array
    end

    it 'returns true for a valid postgres string array' do
      '{"ruby", "on", "rails"}'.should be_valid_postgres_array
    end

    it 'returns true for a valid postgres string array with single quotes' do
      "{'ruby', 'on', 'rails'}".should be_valid_postgres_array
    end

    it 'returns false for string array without quotes' do
      "{ruby, on, rails}".should_not be_valid_postgres_array
    end

    it 'returns false for concatenated strings' do
      '{"ruby""on""rails"}'.should_not be_valid_postgres_array
    end
  end
end