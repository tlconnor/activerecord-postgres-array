module ActiveRecord
  module Coders
    class PgArray
      def self.load(arr)
        new({}).load(arr)
      end

      def self.dump(arr)
        new({}).dump(arr)
      end

      def initialize(base_type, default=nil)
        @base_type = base_type
        @default=default
      end

      def dump(obj)
        obj.nil? ? (@default.nil? ? nil : @default.to_postgres_array(true)) : obj.to_postgres_array(true)
      end

      def load(arr)
        arr.nil? ? @default : arr.from_postgres_array(@base_type)
      end
    end
  end
end

