# frozen_string_literal: true

module Grantinee
  module Engine
    class AbstractEngine

      def initialize
        raise "Not implemented"
      end

      def revoke_permissions!(_data)
        raise "Not implemented"
      end

      def grant_permission!(_data)
        raise "Not implemented"
      end

      def run!(_query)
        raise "Not implemented"
      end

      # Sanitize one value piece
      def sanitize_value
        raise "Not implemented"
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
