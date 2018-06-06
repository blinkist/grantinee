gem "mysql2", ">= 0.4.4", "< 0.6.0"
require "mysql2"

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

      def flush_permissions!
        query = "FLUSH PRIVILEGES;"

        run! query
      end

      def revoke_permissions!(data)
        data  = sanitize(data)
        query = "REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user};" % data

        run! query, data
      end

      def grant_permission!(data)
        data  = sanitize(data)
        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO '%{user}'@'%{host}';"
        else
          "GRANT %{kind}(%{fields}) ON %{table} TO '%{user}'@'%{host}';"
        end % data

        run! query, data
      end

      def run!(query, data={})
        logger.debug query if Grantinee.configuration.verbose
        begin
          @connection.query query
        rescue ::Mysql2::Error => e
          case e.error_number
          when 1269 # Can't revoke all privileges for one or more of the requested users
            logger.debug "User %{user}@%{host} doesn't have any grants yet" % data
          when 1133 # Can't find any matching row in the user table
            logger.error "User %{user}@%{host} doesn't exist yet, create it with \"CREATE USER '%{user}'@'%{host}';\" first" % data
          else
            logger.debug e.error_number
            raise e
          end
        end
      end

    end
  end
end
