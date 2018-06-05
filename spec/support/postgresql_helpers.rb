
# frozen_string_literal: true

module PostgresqlHelpers
  class Postgresql
    def initialize(user: nil, password: nil, database: nil)
      @client = PG::Connection.open(
        user:     user,
        password: password,
        host:     Grantinee.config.dig(:postgresql, :hostname),
        port:     Grantinee.config.dig(:postgresql, :port),
        dbname:   database
      )
    end

    def create_database(database)
      @client.exec "CREATE DATABASE #{database};"
    rescue PG::DuplicateDatabase
      puts "#{database} database already exists, ignoring..."
    end

    def drop_database(database)
      @client.exec "DROP DATABASE #{database};"
    end

    def create_role(role, password)
      @client.exec "CREATE ROLE #{role} NOINHERIT LOGIN PASSWORD '#{password}';"
    rescue PG::DuplicateObject
      puts "#{role} role already exists, ignoring..."
    end

    def drop_role(role)
      @client.exec "DROP ROLE #{role};"
    end

    def create_users_table
      @client.exec "CREATE TABLE users(id VARCHAR(30) PRIMARY KEY, anonymized boolean);"
    rescue StandardError
      drop_users_table
      @client.exec "CREATE TABLE users(id VARCHAR(30) PRIMARY KEY, anonymized boolean);"
    end

    def drop_users_table
      @client.exec "DROP TABLE IF EXISTS users;"
    end

    def create_user_records
      @client.exec "INSERT INTO users(id, anonymized) VALUES('12345e6', false);"
    end

    def close
      @client.close
    end
  end
end
