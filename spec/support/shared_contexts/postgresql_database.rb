# frozen_string_literal: true

require "spec_helper"
require "support/postgresql_helpers"
require "byebug"

RSpec.shared_context "postgresql database" do
  # NOTE: the actual client that we assign permissions for
  let(:postgresql_client) do
    configuration = YAML.safe_load(File.read("spec/fixtures/config_postgresql.yml"))

    PG::Connection.open(
      user:     service,
      password: "fake_password",
      host:     configuration["hostname"],
      port:     configuration["port"],
      dbname:   configuration["database"]
    )
  end

  before do
    pg_admin = PostgresqlHelpers::Postgresql.new
    pg_admin.create_database(database)
    pg_admin.create_role(service, "fake_password")
    pg_admin.close

    db_admin = PostgresqlHelpers::Postgresql.new(database: database)
    db_admin.create_tables
    db_admin.create_user_records
    db_admin.close
  end

  after do
    postgresql_client.close
  end
end
