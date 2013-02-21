ActiveRecord::Schema.define do
  execute "CREATE EXTENSION hstore"

  create_table(:articles, :force => true) do |t|
    t.string        :name
    t.string_array  :languages
    t.integer_array :author_ids
    t.float_array   :prices

    # To make sure we don't interfere with YAML serialization
    t.string        :serialized_column

    # To make sure we don't interfere with activerecord-postgres-hstore
    t.hstore        :hstore_column
  end
  add_hstore_index :articles, :hstore_column
end
