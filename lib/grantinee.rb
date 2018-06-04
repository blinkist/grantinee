require "awesome_print"
require "mysql2"
require "pg"

module Grantinee
  class << self

    def on(database, engine:, &block)
      @parser = Grantinee::Dsl.new
      @parser.instance_eval(&block) if block_given?
    end

  end
end

require 'grantinee/dsl'
require 'grantinee/engine'
require 'grantinee/engine/mysql'
require 'grantinee/engine/postgresql'
