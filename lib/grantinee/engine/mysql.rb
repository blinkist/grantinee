# frozen_string_literal: true

gem 'mysql2', '>= 0.4.4', '< 0.6.0'
require 'mysql2'

module Grantinee
  module Engine
    class Mysql < AbstractEngine
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
        database = sanitize_column_name(data[:database])
        user     = sanitize_value(data[:user])
        host     = sanitize_value(data[:host])

        query = "REVOKE ALL PRIVILEGES ON #{database}.* FROM '#{user}'@'#{host}';"
        run! query, data
      end

      def grant_permission!(data)
        raise "Invalid permission kind" unless WHITELISTED_KINDS.include?(data[:kind]&.downcase)

        database = sanitize_column_name(data[:database])
        kind     = data[:kind]&.upcase
        table    = sanitize_table_name(data[:table])
        user     = sanitize_value(data[:user])
        host     = sanitize_value(data[:host])
        fields   = data[:fields].map { |v| sanitize_column_name(v.to_s) }.join(', ')
        helper   = (kind == "EXECUTE" ? " PROCEDURE " : "")

        query = if data[:fields].empty?
                  "GRANT #{kind} ON #{helper}#{database}.#{table} TO '#{user}'@'#{host}';"
                else
                  "GRANT #{kind}(#{fields}) ON #{database}.#{table} TO '#{user}'@'#{host}';"
                end
        run! query, data
      end

      private

      def sanitize_value(value)
        @connection.escape value
      end

      def sanitize_column_name(name)
        "`#{name.to_s.gsub('`', '``')}`"
      end

      def sanitize_table_name(name)
        sanitize_column_name(name).gsub('.', '`.`')
      end

      def run!(query, data = {})
        logger.info query

        begin
          @connection.query query
        rescue ::Mysql2::Error => e
          case e.error_number
          when 1141, 1269 # Can't revoke all privileges for one or more of the requested users
            logger.debug format("User %{user}@%{host} doesn't have any grants yet", data)
          when 1133 # Can't find any matching row in the user table
            logger.fatal format("User %{user}@%{host} doesn't exist yet, create it with \"CREATE USER '%{user}'@'%{host}';\" first", data) # rubocop:disable Metrics/LineLength
          else
            logger.debug e.error_number
            raise e
          end
        end
      end
    end
  end
end
