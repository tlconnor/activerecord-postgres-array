class Article < ActiveRecord::Base
  serialize :metadata_hash, Hash
  serialize :metadata_json, JSON
end
