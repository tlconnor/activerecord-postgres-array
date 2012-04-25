class String
  def to_postgres_array
    self
  end

  # Validates the array format. Valid formats are:
  # * An empty string
  # * A string like '{10000, 10000, 10000, 10000}'
  # * TODO A multi dimensional array string like '{{"meeting", "lunch"}, {"training", "presentation"}}'
  def valid_postgres_array?
    string_regexp = /[^",\\]+/
    quoted_string_regexp = /"[^"\\]*(?:\\.[^"\\]*)*"/
    number_regexp = /[-+]?[0-9]*\.?[0-9]+/
    validation_regexp = /\{\s*((#{number_regexp}|#{quoted_string_regexp}|#{string_regexp})(\s*\,\s*(#{number_regexp}|#{quoted_string_regexp}|#{string_regexp}))*)?\}/
    !!match(/^\s*('#{validation_regexp}'|#{validation_regexp})?\s*$/)
  end

  # Creates an array from a postgres array string that postgresql spits out.
  def from_postgres_array(base_type = :string)
    if empty?
      []
    else
      elements = match(/\{(.*)\}/).captures.first.gsub(/\\"/, '$ESCAPED_DOUBLE_QUOTE$').split(/(,)(?=(?:[^"]|"[^"]*")*$)/).reject {|e| e == ',' }
      elements = elements.map do |e|
        res = e.gsub('$ESCAPED_DOUBLE_QUOTE$', '"').gsub("\\\\", "\\").gsub(/^"/, '').gsub(/"$/, '').gsub("''", "'").strip
        res == 'NULL' ? nil : res
      end
      if base_type == :decimal
        elements.collect(&:to_d)
      elsif base_type == :integer
        elements.collect(&:to_i)
      else
        elements
      end
    end
  end
end