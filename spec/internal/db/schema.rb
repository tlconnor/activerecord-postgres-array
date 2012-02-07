ActiveRecord::Schema.define do
  create_table(:articles, :force => true) do |t|
    t.string       :name
    t.string_array :languages
  end
end
