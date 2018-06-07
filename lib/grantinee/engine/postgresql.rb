gem "pg", ">= 0.18", "< 2.0"
require "pg"

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

      def flush_permissions!
        # Postgres doesn't need to flush privileges
      end

      def revoke_permissions!(data)
        data  = sanitize(data)
        query = "REVOKE ALL PRIVILEGES ON DATABASE %{database} FROM %{user};" % data

        run! query, data
      end

      def grant_permission!(data)
        data  = sanitize(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO %{user};"
        else
          "GRANT %{kind}(%{fields}) ON TABLE %{table} TO %{user};"
        end % data

        run! query, data
      end

      def run!(query, data={})
        logger.info query
        return @connection.exec query
      end

    end
  end
end
