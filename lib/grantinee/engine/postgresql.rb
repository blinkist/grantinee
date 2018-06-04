require 'pg'

module Grantinee
  module Engine
    class Postgresql < AbstractEngine

      def initialize(database)
        @client = PG::Connection.open(
          user:     Grantinee.config.dig(:postgresql, :username),
          password: Grantinee.config.dig(:postgresql, :password),
          host:     Grantinee.config.dig(:postgresql, :hostname),
          port:     Grantinee.config.dig(:postgresql, :port),
          dbname:   database
        )
      end

      def revoke_permissions!(data)
        query = "REVOKE ALL PRIVILEGES ON DATABASE %{database} FROM %{user};" % data
        run! query
      end

      def grant_permission(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO %{user};"
        else
          "GRANT %{kind}(%{fields}) ON TABLE %{table} TO %{user};"
        end % data
        run! query
      end

      def run!(query)
        ap query
        return @client.exec query
      end

    end
  end
end
