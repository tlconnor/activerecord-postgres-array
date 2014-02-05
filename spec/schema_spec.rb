require 'spec_helper'

describe "Schema" do
  subject(:dump_stream) { StringIO.new }

  before { ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dump_stream) }

  it "can dump the schema" do
    dump_stream.string.should_not be_blank
  end

  it "should dump the schema including the array types" do
    dump_stream.string.should include("t.string_array")
    dump_stream.string.should include("t.float_array")
    dump_stream.string.should include("t.integer_array")
  end

  it "should still dump columns with normal defaults correctly" do
    dump_stream.string.should include(':default => "AbC"')
  end

  it "should dump schemas including defaults for string arrays" do
    dump_stream.string.should include(':default => ["foo", "bar", "baz qux"]')
  end

  it "should dump schemas including defaults for integer arrays" do
    dump_stream.string.should include(":default => [1, 2, 3]")
  end

  it "should dump schemas including defaults for float arrays" do
    dump_stream.string.should include(":default => [12.519267, 16.0]")
  end
end