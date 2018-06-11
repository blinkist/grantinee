# frozen_string_literal: true

require "spec_helper"
require "support/mysql_helpers"
require "mysql2"

RSpec.shared_context "mysql database" do
  let(:db_type) { :mysql }

  # NOTE: the actual client that we assign permissions for
  let(:mysql_client) do
    require "./spec/fixtures/config_mysql"

    Mysql2::Client.new(
      username: user,
      password: "secret",
      host:     Grantinee.configuration.hostname,
      port:     Grantinee.configuration.port,
      database: Grantinee.configuration.database
    )
  end

  before do
    mysql_admin = MysqlHelpers::Mysql.new(user: "root", password: "mysql")
    mysql_admin.create_database(database)
    mysql_admin.create_role(user, "secret")
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
