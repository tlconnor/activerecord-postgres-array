require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  class ArrayTypeMismatch < ActiveRecord::ActiveRecordError
  end

  class Base
    def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      attrs      = {}
      klass      = self.class
      arel_table = klass.arel_table

      attribute_names.each do |name|
        if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
          if include_readonly_attributes || !self.class.readonly_attributes.include?(name)
            value = read_attribute(name)
            if column.type.to_s =~ /_array$/ && value && value.is_a?(Array)
              value = value.to_postgres_array(new_record?)
            elsif klass.serialized_attributes.include?(name)
              value = @attributes[name].serialized_value
            end
            attrs[arel_table[name]] = value
          end
        end
      end

      attrs
    end
  end

  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      POSTGRES_ARRAY_TYPES = %w( string text integer float decimal datetime timestamp time date binary boolean )

      def native_database_types_with_array(*args)
        native_database_types_without_array.merge(POSTGRES_ARRAY_TYPES.inject(Hash.new) {|h, t| h.update("#{t}_array".to_sym => {:name => "#{native_database_types_without_array[t.to_sym][:name]}[]"})})
      end
      alias_method_chain :native_database_types, :array

      # Quotes a value for use in an SQL statement
      def quote_with_array(value, column = nil)
        if value && column && column.sql_type =~ /\[\]$/
          raise ArrayTypeMismatch, "#{column.name} must be an Array or have a valid array value (#{value})" unless value.kind_of?(Array) || value.valid_postgres_array?
          return value.to_postgres_array
        end
        quote_without_array(value,column)
      end
      alias_method_chain :quote, :array
    end

    class Table
      # Adds array type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.string_array :real_energy
      #     t.decimal_array :real_energy, :precision => 18, :scale => 6
      #     ...
      #   end
      PostgreSQLAdapter::POSTGRES_ARRAY_TYPES.each do |column_type|
        define_method("#{column_type}_array") do |*args|
          options = args.extract_options!
          base_type = @base.type_to_sql(column_type.to_sym, options[:limit], options[:precision], options[:scale])
          column_names = args
          column_names.each { |name| column(name, "#{base_type}[]", options) }
        end
      end
    end

    class TableDefinition
      # Adds array type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.string_array :real_energy
      #     t.decimal_array :real_energy, :precision => 18, :scale => 6
      #     ...
      #   end
      PostgreSQLAdapter::POSTGRES_ARRAY_TYPES.each do |column_type|
        define_method("#{column_type}_array") do |*args|
          options = args.extract_options!
          base_type = @base.type_to_sql(column_type.to_sym, options[:limit], options[:precision], options[:scale])
          column_names = args
          column_names.each { |name| column(name, "#{base_type}[]", options) }
        end
      end
    end

    class PostgreSQLColumn < Column
      # Does the type casting from array columns using String#from_postgres_array or Array#from_postgres_array.
      def type_cast_code_with_array(var_name)
        if type.to_s =~ /_array$/
          base_type = type.to_s.gsub(/_array/, '')
          "#{var_name}.from_postgres_array(:#{base_type.parameterize('_')})"
        else
          type_cast_code_without_array(var_name)
        end
      end
      alias_method_chain :type_cast_code, :array

      # Adds the array type for the column.
      def simplified_type_with_array(field_type)
        if field_type =~ /^numeric.+\[\]$/
          :decimal_array
        elsif field_type =~ /character varying.*\[\]/
          :string_array
        elsif field_type =~ /^(?:real|double precision)\[\]$/
          :float_array
        elsif field_type =~ /timestamp.*\[\]/
          :timestamp_array
        elsif field_type =~ /\[\]$/
          field_type.gsub(/\[\]/, '_array').to_sym
        else
          simplified_type_without_array(field_type)
        end
      end
      alias_method_chain :simplified_type, :array
    end
  end
end
