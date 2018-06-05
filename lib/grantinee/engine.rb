module Grantinee
  module Engine
    class << self
      # Get appropriate engine class for the engine name
      def for(engine)
        raise "Engine '#{engine}' is not supported" unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)

        case engine.to_s
        when 'mysql'
          Mysql.new
        when 'postgresql'
          Postgresql.new
        end
      end
    end

  end
end
