class Grantinee::Dsl

  def initialize
    @data = {}
  end


  # Define database and mode
  def on(database, engine, &block)
    @engine = Engine.for engine
    @data[:database] = database

    instance_eval(&block) if block_given?
  end

  # Define user and host
  # Note: revokes permissions for given user
  def user(user, &block)
    @data[:user], @data[:host] = user.to_s.split '@'
    @data[:host] ||= '%'

    @engine.revoke_permissions! @data
    instance_eval(&block) if block_given?
  end

  # Run specific grants
  %w{ select insert update }.each do |kind|
    define_method(kind.to_sym) do |table, fields=[]|
      @engine.grant_permission @data.merge({ kind: kind, table: table, fields: fields })
    end
  end

end
