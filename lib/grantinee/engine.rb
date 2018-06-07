module Grantinee
  module Engine
    class << self

      def logger
        Grantinee.logger
      end

      # Get appropriate engine class for the engine name
      def for(engine)
        logger.debug "Using engine: #{engine}"

        raise "Engine '#{engine}' is not supported" unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)

        case engine.to_s
        when 'mysql'
          require 'grantinee/engine/mysql'
          Mysql.new

        when 'postgresql'
          require 'grantinee/engine/postgresql'
          Postgresql.new

        end
      end
    end

  end
end
