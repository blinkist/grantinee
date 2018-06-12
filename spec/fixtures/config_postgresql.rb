Grantinee.configure do |c|
  c.engine = :postgresql
  c.username = 'postgres'
  c.password = 'postgres'
  c.hostname = ENV['POSTGRES_HOST'] || 'localhost'
  c.port     = 5432
  c.database = 'grantinee_development'
end
