# frozen_string_literal: true

Grantinee.configure do |c|
  c.engine = :mysql
  c.username = 'root'
  c.password = 'mysql'
  c.hostname = ENV['MYSQL_HOST'] || '127.0.0.1'
  c.port     = 3306
  c.database = 'grantinee_test'
end
