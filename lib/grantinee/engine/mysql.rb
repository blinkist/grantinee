require 'mysql2'

module Grantinee
  module Engine
    class Mysql < AbstractEngine

      def initialize(database)
        @client = Mysql2::Client.new(
          username: Grantinee.config.dig(:mysql, :username),
          password: Grantinee.config.dig(:mysql, :password),
          host:     Grantinee.config.dig(:mysql, :hostname),
          port:     Grantinee.config.dig(:mysql, :port),
          database: database
        )
      end

      def revoke_permissions!(data)
        query = "REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user}" % data
        begin
          run! query
        rescue Exception => e
          # MySQL freaks out when there are no grants yet...
        end
      end

      def grant_permission(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO '%{user}'@'%{host}';"
        else
          "GRANT %{kind}(%{fields}) ON %{table} TO '%{user}'@'%{host}';"
        end % data
        run! query
      end

      def run!(query)
        ap query
        return @client.query query
      end

    end
  end
end
