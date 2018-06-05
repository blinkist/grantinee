require 'pg'

module Grantinee
  module Engine
    class Postgresql < AbstractEngine

      def sanitize_value(value)
        @connection.escape_string value
      end


      def initialize
        configuration = Grantinee.configuration

        @connection = PG::Connection.open(
          user:     configuration.username,
          password: configuration.password,
          host:     configuration.hostname,
          port:     configuration.port,
          dbname:   configuration.database
        )
      end

      def revoke_permissions!(data)
        query = "REVOKE ALL PRIVILEGES ON DATABASE %{database} FROM %{user};" % sanitize(data)
        run! query
      end

      def grant_permission!(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO %{user};"
        else
          "GRANT %{kind}(%{fields}) ON TABLE %{table} TO %{user};"
        end % sanitize(data)
        run! query
      end

      def run!(query)
        ap query if Grantinee.configuration.verbose
        return @connection.exec query
      end

    end
  end
end
