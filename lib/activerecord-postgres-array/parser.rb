class ActiveRecordPostgresArray < Rails::Railtie
  # PostgreSQL array parser that handles all types of input.
  #
  # This parser is very simple and unoptimized, but should still
  # be O(n) where n is the length of the input string.
  class Parser
    ARRAY = "ARRAY".freeze
    DOUBLE_COLON = '::'.freeze
    EMPTY_BRACKET = '[]'.freeze
    OPEN_BRACKET = '['.freeze
    CLOSE_BRACKET = ']'.freeze
    COMMA = ','.freeze
    BACKSLASH = '\\'.freeze
    EMPTY_STRING = ''.freeze
    OPEN_BRACE = '{'.freeze
    CLOSE_BRACE = '}'.freeze
    NULL = 'NULL'.freeze
    QUOTE = '"'.freeze
    # Current position in the input string.
    attr_reader :pos

    # Set the source for the input, and any converter callable
    # to call with objects to be created.  For nested parsers
    # the source may contain text after the end current parse,
    # which will be ignored.
    def initialize(source, converter=nil)
      @source = source
      @source_length = source.length
      @converter = converter 
      @pos = -1
      @entries = []
      @recorded = ""
      @dimension = 0
    end

    # Return 2 objects, whether the next character in the input
    # was escaped with a backslash, and what the next character is.
    def next_char
      @pos += 1
      if (c = @source[@pos..@pos]) == BACKSLASH
        @pos += 1
        [true, @source[@pos..@pos]]
      else
        [false, c]
      end
    end

    # Add a new character to the buffer of recorded characters.
    def record(c)
      @recorded << c
    end
    
    # Take the buffer of recorded characters and add it to the array
    # of entries, and use a new buffer for recorded characters.
    def new_entry(include_empty=false)
      if !@recorded.empty? || include_empty
        entry = @recorded
        if entry == NULL && !include_empty
          entry = nil
        elsif @converter
          entry = @converter.call(entry)
        end
        @entries.push(entry)
        @recorded = ""
      end
    end

    # Parse the input character by character, returning an array
    # of parsed (and potentially converted) objects.
    def parse(nested=false)
      # quote sets whether we are inside of a quoted string.
      quote = false
      until @pos >= @source_length
        escaped, char = next_char
        if char == OPEN_BRACE && !quote
          @dimension += 1
          if (@dimension > 1)
            # Multi-dimensional array encounter, use a subparser
            # to parse the next level down.
            subparser = self.class.new(@source[@pos..-1], @converter)
            @entries.push(subparser.parse(true))
            @pos += subparser.pos - 1
          end
        elsif char == CLOSE_BRACE && !quote
          @dimension -= 1
          if (@dimension == 0)
            new_entry
            # Exit early if inside a subparser, since the
            # text after parsing the current level should be
            # ignored as it is handled by the parent parser.
            return @entries if nested
          end
        elsif char == QUOTE && !escaped
          # If already inside the quoted string, this is the
          # ending quote, so add the entry.  Otherwise, this
          # is the opening quote, so set the quote flag.
          new_entry(true) if quote
          quote = !quote
        elsif char == COMMA && !quote
          # If not inside a string and a comma occurs, it indicates
          # the end of the entry, so add the entry.
          new_entry
        else
          # Add the character to the recorded character buffer.
          record(char)
        end
      end
      raise "array dimensions not balanced" unless @dimension == 0
      @entries
    end
  end
end