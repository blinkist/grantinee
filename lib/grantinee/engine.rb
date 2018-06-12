# frozen_string_literal: true

module Grantinee
  module Engine
    class << self
      # Get appropriate engine class for the engine name
      def for(engine)
        logger.debug "Using engine: #{engine}"
        unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)
          raise "Engine '#{engine}' is not supported"
        end

        case engine.to_s
        when 'mysql'
          require 'grantinee/engine/mysql'
          Mysql.new

        when 'postgresql'
          require 'grantinee/engine/postgresql'
          Postgresql.new

        end
      end

      def detect_active_record_connection!
        @configuration = Grantinee::Configuration.new

        # config/environment.rb is a good candidate for a Rails app...
        return unless File.exist? './config/environment.rb'
        require './config/environment'

        # ...by now we should have ActiveRecord::Base if it really was Rails app
        return unless defined?(ActiveRecord::Base)

        configure_for_active_record(ActiveRecord::Base.connection_config)
      end

      private

      def logger
        Grantinee.logger
      end

      def configure_for_active_record(ar_config)
        @configuration.username = ar_config[:username]
        @configuration.password = ar_config[:password]
        @configuration.hostname = ar_config[:host]
        @configuration.port     = ar_config[:port]
        @configuration.database = ar_config[:database]
        @configuration.engine   = case ar_config[:adapter]
        when 'mysql', 'mysql2'
          :mysql
        when 'postgresql', 'pg'
          :postgresql
        end
      end
    end
  end
end
