# frozen_string_literal: true

module Grantinee
  module Engine
    WHITELISTED_KINDS = %w[all usage select update insert].freeze

    class << self
      # Get appropriate engine class for the engine name
      def for(engine)
        logger.debug "Using engine: #{engine}"
        unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)
          raise "Engine '#{engine}' is not supported"
        end

        case engine.to_s
        when 'mysql', 'mysql2'
          require 'grantinee/engine/mysql'
          Mysql.new

        when 'postgresql', 'pg'
          require 'grantinee/engine/postgresql'
          Postgresql.new

        end
      end

      def detect_active_record_connection!
        return unless defined?(ActiveRecord::Base)

        configure_for_active_record(ActiveRecord::Base.connection_config)
      end

      private

      def logger
        Grantinee.logger
      end

      def configure_for_active_record(ar_config)
        if ar_config[:url]
          configure_for_active_record_url(ar_config)
        else
          configure_for_active_record_fields(ar_config)
        end

        Grantinee.configuration.engine = case ar_config[:adapter]
        when 'mysql', 'mysql2'
          :mysql
        when 'postgresql', 'pg'
          :postgresql
        end
      end

      def configure_for_active_record_url(ar_config)
        Grantinee.configuration.url = ar_config[:url]
      end

      def configure_for_active_record_fields(ar_config)
        Grantinee.configuration.username = ar_config[:username]
        Grantinee.configuration.password = ar_config[:password]
        Grantinee.configuration.hostname = ar_config[:host]
        Grantinee.configuration.port     = ar_config[:port]
        Grantinee.configuration.database = ar_config[:database]
      end
    end
  end
end
