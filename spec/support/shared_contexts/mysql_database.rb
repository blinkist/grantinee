# frozen_string_literal: true

require "spec_helper"
require "support/mysql_helpers"
require "mysql2"

RSpec.shared_context "mysql database" do
  let(:db_type) { :mysql }

  # NOTE: the actual client that we assign permissions for
  let(:mysql_client) do
    load "./spec/fixtures/config_mysql.rb"

    Mysql2::Client.new(
      username: users.first,
      password: "secret",
      host:     Grantinee.configuration.hostname,
      port:     Grantinee.configuration.port,
      database: Grantinee.configuration.database
    )
  end

  before do
    load "./spec/fixtures/config_mysql.rb"

    mysql_admin = MysqlHelpers::Mysql.new(user: "root", password: "mysql")
    mysql_admin.create_database(database)
    users.each do |user|
      mysql_admin.create_role(user, "secret")
    end

    mysql_admin.close

    db_admin = MysqlHelpers::Mysql.new(user: "root", password: "mysql", database: database)
    db_admin.create_tables
    db_admin.create_user_records
    db_admin.close
  end

  after do
    mysql_client.close
  end
end
