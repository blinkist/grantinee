# frozen_string_literal: true

require "spec_helper"
require "support/postgresql_helpers"
require "byebug"

RSpec.shared_context "postgresql database" do
  # NOTE: the actual client that we assign permissions for
  let(:postgresql_client) do
    PG::Connection.open(
      user:     service,
      password: "fake_password",
      host:     Grantinee.config.dig(:postgresql, :hostname),
      port:     Grantinee.config.dig(:postgresql, :port),
      dbname:   database
    )
  end

  before do
    pg_admin = PostgresqlHelpers::Postgresql.new
    pg_admin.create_database(database)
    pg_admin.create_role(service, "fake_password")
    pg_admin.close

    db_admin = PostgresqlHelpers::Postgresql.new(database: database)
    db_admin.create_users_table
    db_admin.create_user_records
    db_admin.close
  end

  after do
    postgresql_client.close
    pg_admin = PostgresqlHelpers::Postgresql.new
    pg_admin.drop_database(database)
    pg_admin.close
  end
end
