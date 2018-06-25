# frozen_string_literal: true

require 'logger'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self
    # Allow configuration using a block
    def configure
      yield configuration
    end

    # Returns configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def logger
      configuration.logger
    end

    def logger=(logger)
      configuration.logger = logger
    end

    extend Gem::Deprecate
    deprecate :logger=, "Please provide logger via configure block", 2018, 7
  end
end

# Load internal stuffs
require 'grantinee/configuration'
require 'grantinee/engine'
require 'grantinee/cli'
require 'grantinee/dsl'
require 'grantinee/executor'
require 'grantinee/engine/abstract_engine'
