# frozen_string_literal: true

require "spec_helper"
require "support/mysql_helpers"
require "mysql2"

RSpec.shared_context "mysql database" do
  # NOTE: the actual client that we assign permissions for
  let(:mysql_client) do
    configuration = YAML.safe_load(File.read("spec/fixtures/config_mysql.yml"))

    Mysql2::Client.new(
      username: service,
      password: "fake_password",
      host:     configuration["hostname"],
      port:     configuration["port"],
      database: configuration["database"]
    )
  end

  before do
    mysql_admin = MysqlHelpers::Mysql.new
    mysql_admin.create_database(database)
    mysql_admin.create_role(service, "fake_password")
    mysql_admin.close

    db_admin = MysqlHelpers::Mysql.new(database: database)
    db_admin.create_tables
    db_admin.create_user_records
    db_admin.close
  end

  after do
    mysql_client.close
  end
end