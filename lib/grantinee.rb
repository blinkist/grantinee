# frozen_string_literal: true

require 'awesome_print'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self

    def detect_environment
      @configuration = Grantinee::Configuration.new

      if File.exist? 'config/environment.rb'
        require_relative 'config/environment'
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
require 'grantinee/engine/mysql'
require 'grantinee/engine/postgresql'
