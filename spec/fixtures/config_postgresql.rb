Grantinee.configure do |c|
  c.engine = 'postgresql'
  c.username = 'postgres'
  c.password = 'postgres'
  c.hostname = 'postgres'
  c.port     = 5432
  c.database = 'grantinee_test'
end
