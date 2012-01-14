class String

  def to_postgres_array
    self
  end

  # Validates the array format. Valid formats are:
  # * An empty string
  # * A string like '{10000, 10000, 10000, 10000}'
  # * TODO A multi dimensional array string like '{{"meeting", "lunch"}, {"training", "presentation"}}'
  def valid_postgres_array?
    # TODO validate formats above
    true
  end

  # Creates an array from a postgres array string that postgresql spits out.
  def from_postgres_array(base_type = :string)
    if empty?
      return []
    else
      elements = match(/^\{(.+)\}$/).captures.first.split(",")
      elements = elements.map do |e|
        e = e.gsub(/\\"/, '"')
        e = e.gsub(/^\"/, '')
        e = e.gsub(/\"$/, '')
        e = e.strip
      end
      
      if base_type == :decimal
        return elements.collect(&:to_d)
      else
        return elements
      end
    end
  end
end