# frozen_string_literal: true

module Grantinee
  class Executor
    def initialize(dsl, engine)
      @dsl    = dsl
      @engine = engine
    end

    def run!
      revoke_permissions
      grant_permissions
      flush_permissions
    end

    private

    def revoke_permissions
      @dsl.permissions.each { |data| @engine.revoke_permissions!(data) }
    end

    def grant_permissions
      @dsl.permissions.each { |data| @engine.grant_permission!(data) }
    end

    def flush_permissions
      @engine.flush_permissions!
    end
  end
end
