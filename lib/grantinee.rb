require 'awesome_print'

# Grantinee module is where the magic at ;-)
module Grantinee
  class << self

    # Define Grantinee.config and set some defaults
    # Config should be set using Grantinee.config { ... } or via -c option
    def config(&block)
      @config = {
        mysql: {
          hostname: 'localhost',
          port:     3306,
          username: 'root',
          password: 'mysql'
        },
        postgresql: {
          hostname: 'localhost',
          port:     5432,
          username: 'postgres',
          password: 'postgres'
        }
      }

      instance_eval(&block) if block_given?
      return @config
    end

  end
end

# Load internal stuffs
require 'grantinee/dsl'
require 'grantinee/engine'
require 'grantinee/engine/abstract_engine'
require 'grantinee/engine/mysql'
require 'grantinee/engine/postgresql'
