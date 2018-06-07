# This is a sample configuration file for you to play with
Grantinee.configure do |c|
  c.engine = :mysql

  case c.engine
  when :mysql
    c.username = 'root'
    c.password = 'mysql'
    c.hostname = 'localhost'
    c.port     = 3306
    c.database = 'grantinee_development'

  when :postgresql
    c.username = 'postgres'
    c.password = 'postgres'
    c.hostname = 'localhost'
    c.port     = 5432
    c.database = 'grantinee_development'
  end
end
