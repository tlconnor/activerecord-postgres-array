ActiveRecord::Schema.define do
  execute "CREATE EXTENSION hstore"

  create_table(:articles, :force => true) do |t|
    t.string        :name
    t.string_array  :languages
    t.integer_array :author_ids
    t.float_array   :prices
    t.string_array :defaults, :default => ['foo', 'bar']

    # To make sure we don't interfere with YAML serialization
    t.string        :serialized_column

    # To make sure we don't interfere with activerecord-postgres-hstore
    t.hstore        :hstore_column
  end
  add_hstore_index :articles, :hstore_column

  # Creating a new model table because we don't seem to be able to dump schema for hstore tables well
  create_table(:default_articles, :force => true) do |t|
    t.string        :name, :default => 'AbC'
    t.string_array  :languages
    t.integer_array :author_ids, :default => [1,2,3]
    t.float_array   :prices, :default => [12.519267, 16.0]
    t.string_array :defaults, :default => ['foo', 'bar', 'baz qux']
  end
end
