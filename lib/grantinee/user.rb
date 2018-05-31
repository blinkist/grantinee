# require 'grantinee/permission'

class Grantinee::User

  def initialize(name, &block)
    case name
    when Symbol
      @name = name.to_s
      @host = 'localhost'
    when String
      @name, @host = name.split('@')
    end

    @permissions = []
    instance_eval(&block)

    build_permission
  end

  def select(table, fields=nil)
    @permissions << Grantinee::Permission.new(:select, table, fields)
  end

  def insert(table, fields=nil)
    @permissions << Grantinee::Permission.new(:insert, table, fields)
  end

  def update(table, fields=nil)
    @permissions << Grantinee::Permission.new(:update, table, fields)
  end

  def build_permission
    @permissions.map { |p|
      p.build_permission.gsub('{{USER}}', @name).gsub('{{HOST}}', @host)
    }
  end

end
