require "awesome_print"

# module Grantinee
#
#   def self.on(name, &block)
#     Grantinee::Database.new(name, &block).build_permission
#   end
#
# end

module Grantinee
  class << self

    def on(database, mode:, &block)
      @database = database
      @users = []

      instance_eval(&block) if block_given?

      @users = @users.flat_map do |user|
        user.map { |p| p.merge({ database: database }) }
      end
    end


    def user(user, &block)
      @permissions = []

      instance_eval(&block) if block_given?

      @users << @permissions.map { |p| p.merge({ user: user }) }
    end


    def select(table, fields=[])
      @permissions << { kind: 'select', table: table, fields: fields }
    end

    def insert(table, fields=[])
      @permissions << { kind: 'insert', table: table, fields: fields }
    end

    def update(table, fields=[])
      @permissions << { kind: 'update', table: table, fields: fields }
    end


    def format_permission
      case @mode
      when 'mysql'

      when 'postgres'
      else
        raise "Mode not supported"
      end
    end
  end
end

# require "grantinee/version"
# require "grantinee/database"
# require "grantinee/user"
# require "grantinee/permission"
