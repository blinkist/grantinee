# frozen_string_literal: true

module Grantinee
  module Engine
    class << self
      # Get appropriate engine class for the engine name
      def for(engine)
        raise "Engine '#{engine}' is not supported" unless Configuration::SUPPORTED_ENGINES.include?(engine.to_s)

        case engine.to_s
        when 'active_record'
          require 'grantinee/engine/active_record'
          ActiveRecord.new

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
