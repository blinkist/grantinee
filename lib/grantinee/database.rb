# require 'grantinee/user'

class Grantinee::Database

  def initialize(name, &block)
    @name = name
    @users = []

    instance_eval(&block)
  end

  def user(name, &block)
    @users << Grantinee::User.new(name, &block)
  end

  def build_permission
    @users.flat_map { |u|
      u.build_permission.map { |p|
        p.gsub('{{DATABASE}}', @name)
      }
    }
  end

end
