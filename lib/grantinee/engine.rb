# frozen_string_literal: true

module Grantinee
  module Engine
    class << self
      # Get appropriate engine class for the engine name
      def for(engine)
        unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)
          raise "Engine '#{engine}' is not supported"
        end

        case engine.to_s
        when 'active_record'
          ActiveRecord.new
        when 'mysql'
          Mysql.new
        when 'postgresql'
          Postgresql.new
        end
      end
    end

  end
end
