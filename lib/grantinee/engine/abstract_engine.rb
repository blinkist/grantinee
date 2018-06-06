module Grantinee
  module Engine
    class AbstractEngine
      NOT_IMPLEMENTED = "Not implemented"

      def initialize
        raise NOT_IMPLEMENTED
      end

      def flush_permissions!
        raise NOT_IMPLEMENTED
      end

      def revoke_permissions!(data)
        raise NOT_IMPLEMENTED
      end

      def grant_permission!(data)
        raise NOT_IMPLEMENTED
      end

      def run!(query)
        raise NOT_IMPLEMENTED
      end

      # Sanitize one value piece
      def sanitize_value
        raise NOT_IMPLEMENTED
      end

      # Sanitize the data
      # Escapes values that are strings or symbols
      # Escapes each value from an array
      def sanitize(data)
        data.each do |key, value|
          data[key] = case value
          when String, Symbol
            sanitize_value(value.to_s)
          when Array
            value.map { |v| sanitize_value(v.to_s) }
          else
            raise "Unsupported data type: #{value.class}"
          end
        end
      end

    end
  end
end
