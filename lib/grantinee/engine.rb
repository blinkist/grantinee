module Grantinee
  module Engine
    class << self

      # Get appropriate engine class for the engine name
      def for(engine, database)
        case engine.to_s
        when 'mysql'
          Mysql.new database

        when 'postgresql'
          Postgresql.new database

        else
          raise "Engine '#{engine}' is not supported"
        end
      end
    end

  end
end
