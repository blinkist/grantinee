module Grantinee
  class Dsl

    attr_accessor :permissions

    # Allow evaluation of the code coming from the Grantinee file
    def self.eval(commands)
      self.new { eval(commands, binding) }
    end

    # Initialize defaults and start processing
    def initialize(&block)
      @permissions = []
      @data        = {}

      instance_eval(&block)
    end

    def logger
      Grantinee.logger
    end

    # Define database and mode
    def on(database, &block)
      logger.debug "Got database: #{ database }"

      @data[:database] = database

      instance_eval(&block) if block_given?
    end

    # Define user and host
    # Note: revokes all permissions for given user first
    def user(user, &block)
      logger.debug "Got user: #{ user }"

      @data[:user], @data[:host] = user.to_s.split '@'
      @data[:host] ||= '%'

      instance_eval(&block) if block_given?
    end

    # Define permission grants
    %w{ all usage select insert update }.each do |kind|
      define_method(kind.to_sym) do |table, fields=[]|
        logger.debug "Got table: #{table}, fields: #{fields}"

        @permissions << @data.merge({
          kind:   kind,
          table:  table,
          fields: fields
        })
      end
    end

  end
end
