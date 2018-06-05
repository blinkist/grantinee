# frozen_string_literal: true

require 'mysql2'

module Grantinee
  module Engine
    class ActiveRecord < AbstractEngine

      def sanitize_value(value)
        value
      end

      def initialize
        @connection = ActiveRecord::Base.connection
      end

      def revoke_permissions!(data)
        query = ["REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user};", data]
        begin
          run! query
        rescue Exception => e
          # MySQL freaks out when there are no grants yet...
        end
      end

      def grant_permission!(data)
        query = if data[:fields].empty?
                  "GRANT %{kind} ON %{table} TO '%{user}'@'%{host}';"
                else
                  "GRANT %{kind}(%{fields}) ON %{table} TO '%{user}'@'%{host}';"
        end
        run! [query, data]
      end

      def run!(query)
        ap query if Grantinee.configuration.verbose
        @connection.execute query
      end

    end
  end
end
