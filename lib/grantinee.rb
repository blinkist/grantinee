require 'logger'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self

    def logger
      @logger ||= ::Logger.new($stderr)
    end

    def detect_active_record_connection!
      @configuration = Grantinee::Configuration.new

      # config/environment.rb is a good candidate for a Rails app...
      if File.exists? './config/environment.rb'
        require './config/environment'

        # ...by now we should have ActiveRecord::Base if it really was Rails app
        if defined?(ActiveRecord::Base)
          ar_config = ActiveRecord::Base.connection_config

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
