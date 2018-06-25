
# frozen_string_literal: true

require "yaml"

module MysqlHelpers
  class Mysql
    def initialize(user: nil, password: nil, database: nil)
      load "./spec/fixtures/config_mysql.rb"

      @client = Mysql2::Client.new(
        username: user,
        password: password,
        host:     Grantinee.configuration.hostname,
        port:     Grantinee.configuration.port,
        database: database
      )
    end

    def create_database(database)
      @client.query "CREATE DATABASE #{database};"
    rescue Mysql2::Error => error
      puts error
    end

    def drop_database(database)
      @client.query "DROP DATABASE #{database};"
    end

    def create_role(role, password)
      @client.query "CREATE USER '#{role}'@'localhost' IDENTIFIED BY '#{password}';"
      @client.query "CREATE USER '#{role}'@'%' IDENTIFIED BY '#{password}';"
    rescue Mysql2::Error
      drop_role(role)
      @client.query "CREATE USER '#{role}'@'localhost' IDENTIFIED BY '#{password}';"
      @client.query "CREATE USER '#{role}'@'%' IDENTIFIED BY '#{password}';"
    end

    def drop_role(role)
      @client.query "DROP USER '#{role}'@'localhost';"
      @client.query "DROP USER '#{role}'@'%';"
    end

    def create_tables
      create_users_table
      create_lists_users_table
    end

    def create_users_table
      @client.query "CREATE TABLE users (id VARCHAR(30) PRIMARY KEY, "\
                    "anonymized boolean);"
    rescue Mysql2::Error
      drop_table(:users)
      @client.query "CREATE TABLE users (id VARCHAR(30) PRIMARY KEY,"\
                    "anonymized boolean);"
    end

    def create_lists_users_table
      @client.query "CREATE TABLE lists_users (id VARCHAR(30) PRIMARY KEY, "\
                    "list_name varchar(30), user_id varchar(30));"
    rescue StandardError
      drop_table(:lists_users)
      @client.query "CREATE TABLE lists_users (id VARCHAR(30) PRIMARY KEY, "\
                    "list_name varchar(30), user_id varchar(30));"
    end

    def drop_table(name)
      @client.query "DROP TABLE #{name};"
    end

    def create_user_records
      @client.query "INSERT INTO users (id, anonymized) VALUES ('1234', false);"
    rescue StandardError => error
      puts error
    end

    def close
      @client.close
    end
  end
end
