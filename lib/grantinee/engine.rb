module Grantinee
  module Engine
    class << self

      # Get appropriate engine class for the engine name
      def for(engine)
        case engine.to_s
        when 'mysql'
          Mysql.new

        when 'postgresql'
          Postgresql.new

        else
          raise "Engine '#{engine}' is not supported"
        end
      end


      def revoke_permissions!(data)
        raise "Not implemented"
      end

      def grant_permission(data)
        raise "Not implemented"
      end

    end
  end
end
