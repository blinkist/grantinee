# frozen_string_literal: true

require 'mysql2'

module Grantinee
  module Engine
    class Mysql < AbstractEngine

      def sanitize_value(value)
        @connection.escape value
      end


      def initialize
        configuration = Grantinee.configuration

        @connection = Mysql2::Client.new(
          username: configuration.username,
          password: configuration.password,
          host:     configuration.hostname,
          port:     configuration.port,
          database: configuration.database
        )
      end

      def revoke_permissions!(data)
        query = "REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user};" % sanitize(data)
        begin
          run! query
        rescue StandardError
          # MySQL freaks out when there are no grants yet...
        end
      end

      def grant_permission!(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO '%{user}'@'%{host}';"
        else
          "GRANT %{kind}(%{fields}) ON %{table} TO '%{user}'@'%{host}';"
        end % sanitize(data)
        run! query
      end

      def run!(query)
        ap query if Grantinee.configuration.verbose
        return @connection.query query
      end

    end
  end
end
