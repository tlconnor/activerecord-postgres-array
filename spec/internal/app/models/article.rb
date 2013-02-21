class Article < ActiveRecord::Base
  serialize :serialized_column
  serialize :hstore_column, ActiveRecord::Coders::Hstore
end