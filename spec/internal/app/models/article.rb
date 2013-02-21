class Article < ActiveRecord::Base
  serialize :serialized_column
end