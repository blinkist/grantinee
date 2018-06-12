Grantinee.configure do |c|
  c.engine = :mysql
  c.username = 'root'
  c.password = 'mysql'
  c.hostname = ENV['MYSQL_HOST'] || 'localhost'
  c.port     = 3306
  c.database = 'grantinee_development'
end
