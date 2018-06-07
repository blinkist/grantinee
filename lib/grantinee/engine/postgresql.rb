gem "pg", ">= 0.18", "< 2.0"
require "pg"

module Grantinee
  module Engine
    class Postgresql < AbstractEngine

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


      private

      def sanitize_value(value)
        @connection.escape_string value.to_s
      end

      def sanitize_column_name(name)
        @connection.escape_string name.to_s
      end

      def sanitize_table_name(name)
        @connection.escape_string name.to_s
      end

      def run!(query, data={})
        logger.info query

        begin
          @connection.exec query
        rescue PG::Error => e
          case e
          when PG::UndefinedObject
            logger.fatal "User %{user}@%{host} doesn't exist yet, create it with \"CREATE ROLE %{user};\" first" % data
          else
            logger.debug e.class
            raise e
          end
        end
      end

    end
  end
end
