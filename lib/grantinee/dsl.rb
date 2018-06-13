# frozen_string_literal: true

module Grantinee
  class Dsl
    attr_accessor :permissions

    # Allow evaluation of the code coming from the Grantinee file
    def self.eval(commands)
      new.tap do |x|
        x.eval(commands)
      end
    end

    # Initialize defaults
    def initialize
      @permissions = []
      @data        = {}
    end

    def eval(commands)
      instance_eval(commands)
    end

    # Define database and mode
    def on(database, &block)
      logger.debug "Got database: #{database}"

      @data[:database] = database

      instance_eval(&block) if block_given?
    end

    # Define user and host
    # Note: revokes all permissions for given user first
    def user(user, &block)
      old_user = @current_user

      logger.debug "Got user: #{user}"

      @data[:user], @data[:host] = user.to_s.split '@'
      @data[:host] ||= '%'

      @current_user = @data
      instance_eval(&block) if block_given?
    ensure
      @current_user = old_user
    end

    # Define permission grants
    Engine::WHITELISTED_KINDS.each do |kind|
      define_method(kind.to_sym) do |table, fields = []|
        logger.debug "Got table: #{table}, fields: #{fields}"

        @permissions << @data.merge(
          kind:   kind,
          table:  table,
          fields: fields,
        ).merge(@current_user)
      end
    end

    private

    def logger
      Grantinee.logger
    end
  end
end
