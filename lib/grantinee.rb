# frozen_string_literal: true
require 'logger'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self
    attr_reader :logger
    
    # Allow configuration using a block
    def configure
      yield @configuration = Grantinee::Configuration.new
    end

    # Returns configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def detect_active_record_connection!
      @configuration = Grantinee::Configuration.new

      # config/environment.rb is a good candidate for a Rails app...
      return unless File.exist? './config/environment.rb'
      require './config/environment'

      # ...by now we should have ActiveRecord::Base if it really was Rails app
      return unless defined?(ActiveRecord::Base)

      configure_for_active_record(ActiveRecord::Base.connection_config)
    end

    def logger=(logger)
      @logger = logger
    end

    private

    def configure_for_active_record(ar_config)
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

# Load internal stuffs
require 'grantinee/configuration'
require 'grantinee/cli'
require 'grantinee/dsl'
require 'grantinee/executor'
require 'grantinee/engine'
require 'grantinee/engine/abstract_engine'
