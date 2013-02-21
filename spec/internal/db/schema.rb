ActiveRecord::Schema.define do
  create_table(:articles, :force => true) do |t|
    t.string        :name
    t.string_array  :languages
    t.integer_array :author_ids
    t.float_array   :prices

    # To make sure we don't interfere with YAML serialization
    t.string        :serialized_column
  end
end
