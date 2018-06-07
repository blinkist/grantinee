module Grantinee
  module Engine
    class AbstractEngine
      NOT_IMPLEMENTED = "Not implemented"

      def initialize
        raise NOT_IMPLEMENTED
      end

      def logger
        Grantinee.logger
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

      def run!(query, data={})
        raise NOT_IMPLEMENTED
      end

      # Sanitize one value piece
      def sanitize_value
        raise NOT_IMPLEMENTED
      end

      # Sanitize column name
      def sanitize_column_name(name)
        raise NOT_IMPLEMENTED
      end

      # Sanitize table name
      def sanitize_table_name
        raise NOT_IMPLEMENTED
      end

      # Sanitize the data
      def sanitize(data)
        data.inject({}) do |memo, (key, value)|
          memo[key] = case key
          when :user, :host
            sanitize_column_name(value)
          when :table # table
            sanitize_table_name(value)
          when :fields # columns
            value.map { |v| sanitize_column_name(v.to_s) }.join(', ')
          else # values
            sanitize_value(value.to_s)
          end
          memo
        end
      end

    end
  end
end
