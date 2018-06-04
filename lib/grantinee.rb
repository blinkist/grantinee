require "awesome_print"
require "mysql2"
require "pg"

module Grantinee
  class << self

    # Define database and mode
    def on(database, mode:, &block)
      @database = database
      @mode     = mode

      instance_eval(&block) if block_given?
    end

    # Define user and host
    # Note: revokes permissions for given user
    def user(user, &block)
      @user, @host   = user.to_s.split '@'
      @host        ||= '%'

      revoke_permissions!
      instance_eval(&block) if block_given?
    end

    # Run specific grants
    %w{ select insert update }.each do |kind|
      define_method(kind.to_sym) do |table, fields=[]|
        grant_permission kind: kind, table: table, fields: fields
      end
    end


    private

    # Revoke permissions for specific @user
    def revoke_permissions!
      data = {
        user: @user
      }

      query = case @mode.to_s
      when 'mysql'
        query = "REVOKE ALL PRIVILEGES, GRANT OPTION FROM %{user}" % data
        ap query

      when 'postgres'
        query = "REVOKE ALL PRIVILEGES FROM %{user};" % data
        ap query

      else
        raise "Mode not supported"
      end

      results = client.query query
    end

    # Grant specific permission
    def grant_permission(kind:, table:, fields:)
      data = {
        database: @database,
        user:     @user,
        host:     @host,
        kind:     kind,
        table:    table,
        fields:   fields.join(', ')
      }

      query = case @mode.to_s
      when 'mysql'
        client = Mysql2::Client.new username: 'root', password: 'mysql'

        query = if data[:fields].empty?
          "GRANT %{kind} ON %{database}.%{table} TO '%{user}'@'%{host}';"
        else
          "GRANT %{kind}(%{fields}) ON %{database}.%{table} TO '%{user}'@'%{host}';"
        end % data

      when 'postgres'
        client = PG::Connection.open user: 'postgres', password: 'postgres', host: 'localhost'

        query = if data[:fields].empty?
          "GRANT %{kind} ON %{table} TO %{user};"
        else
          "GRANT %{kind}(%{fields}) ON %{table} TO %{user};"
        end % data

      else
        raise "Mode not supported"
      end

      results = client.query query
    end

  end
end
