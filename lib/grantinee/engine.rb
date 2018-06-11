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

      private

      def logger
        Grantinee.logger
      end
    end
  end
end
