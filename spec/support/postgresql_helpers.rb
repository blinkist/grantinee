
# frozen_string_literal: true

require "yaml"

module PostgresqlHelpers
  class Postgresql
    def initialize(user: nil, password: nil, database: nil)
      configuration = YAML.safe_load(File.read("spec/fixtures/config_postgresql.yml"))

      @client = PG::Connection.open(
        user:     user,
        password: password,
        host:     configuration["hostname"],
        port:     configuration["port"],
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

    def create_tables
      create_users_table
      create_lists_users_table
    end

    def create_users_table
      @client.exec "CREATE TABLE users(id VARCHAR(30) PRIMARY KEY, "\
                   "anonymized boolean, 'email.primary' varchar(30));"
    rescue StandardError
      drop_table(:users)
      @client.exec "CREATE TABLE users(id VARCHAR(30) PRIMARY KEY, anonymized boolean);"
    end

    def create_lists_users_table
      @client.exec "CREATE TABLE lists_users(id VARCHAR(30) PRIMARY KEY, "\
                   "list_name varchar(30), user_id varchar(30));"
    rescue StandardError
      drop_table(:lists_users)
      @client.exec "CREATE TABLE lists_users(id VARCHAR(30) PRIMARY KEY, "\
                   "list_name varchar(30), user_id varchar(30));"
    end

    def drop_table(name)
      @client.exec "DROP TABLE IF EXISTS #{name};"
    end

    def create_user_records
      @client.exec "INSERT INTO users(id, anonymized) VALUES('1234', false);"
    end

    def close
      @client.close
    end
  end
end
