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

  when :mysql_url
    c.url = 'mysql://root:mysql@localhost:3306/grantinee_development'

  when :postgresql
    c.username = 'postgres'
    c.password = 'postgres'
    c.hostname = 'localhost'
    c.port     = 5432
    c.database = 'grantinee_development'

  when :postgresql_url
    c.url = 'postgres://postgres:postgres@localhost:5432/grantinee_development'

  end
end
