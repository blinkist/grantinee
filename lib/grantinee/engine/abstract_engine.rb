module Grantinee
  module Engine
    class AbstractEngine

      def initialize
        raise "Not implemented"
      end

      def revoke_permissions!(data)
        raise "Not implemented"
      end

      def grant_permission(data)
        raise "Not implemented"
      end

      def run!(query)
        raise "Not implemented"
      end

    end
  end
end
