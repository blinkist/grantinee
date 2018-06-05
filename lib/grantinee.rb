# Grantinee module is where the magic at ;-)
module Grantinee
  class << self

    def detect_environment
      @configuration = Grantinee::Configuration.new

      if File.exists? './config/environment.rb'
        require './config/environment'
        ar_configuration = ActiveRecord::Base.connection.instance_values['config']
        @configuration.engine = case ar_configuration[:adapter]
        when 'mysql', 'mysql2'
          :mysql
        when 'postgresql', 'pg'
          :postgresql
        end

        @configuration.username = ar_configuration[:username]
        @configuration.password = ar_configuration[:password]
        @configuration.hostname = ar_configuration[:host]
        @configuration.port     = ar_configuration[:port]
        @configuration.database = ar_configuration[:database]

        return true
      end
      false
    end

    # Allow configuration using a block
    def configure
      yield @configuration      = Grantinee::Configuration.new
      @configuration.configured = true
    end

    # Returns configuration
    def configuration
      if configured?
        @configuration
      else
        raise "Not configured"
      end
    end

    # Returns true if the library was configured
    def configured?
      @configuration
    end

  end
end

# Load internal stuffs
require 'grantinee/configuration'
require 'grantinee/dsl'
require 'grantinee/engine'
require 'grantinee/engine/abstract_engine'
