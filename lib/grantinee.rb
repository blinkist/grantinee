# frozen_string_literal: true
require 'logger'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self
    attr_reader :logger

    # Allow configuration using a block
    def configure
      yield configuration
    end

    # Returns configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def logger=(logger)
      @logger = logger
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
