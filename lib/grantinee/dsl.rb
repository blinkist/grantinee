module Grantinee
  class Dsl

    # Allow evaluation of the code coming from the Grantinee file
    def self.eval(commands)
      self.new { eval(commands, binding) }
    end

    # Initialize defaults and start processing
    def initialize(&block)
      @data = {}

      instance_eval(&block)
    end

    # Define database and mode
    def on(database, engine, &block)
      @engine = Grantinee::Engine.for engine, database
      @data[:database] = database

      instance_eval(&block) if block_given?
    end

    # Define user and host
    # Note: revokes all permissions for given user first
    def user(user, &block)
      @data[:user], @data[:host] = user.to_s.split '@'
      @data[:host] ||= '%'

      @engine.revoke_permissions! @data
      instance_eval(&block) if block_given?
    end

    # Define permission grants
    %w{ all usage select insert update }.each do |kind|
      define_method(kind.to_sym) do |table, fields=[]|
        @engine.grant_permission @data.merge({ kind: kind, table: table, fields: fields.join(', ') })
      end
    end

  end
end
