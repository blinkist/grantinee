# frozen_string_literal: true

require "spec_helper"
require "support/postgresql_helpers"
require "pg"

RSpec.shared_context "postgresql database" do
  let(:db_type) { :postgresql }

  # NOTE: the actual client that we assign permissions for
  let(:postgresql_client) do
    require "./spec/fixtures/config_postgresql"

    PG::Connection.open(
      user:     user,
      password: "fake_password",
      host:     Grantinee.configuration.hostname,
      port:     Grantinee.configuration.port,
      dbname:   Grantinee.configuration.database
    )
  end

  before do
    options = { user: "postgres", password: "postgres" }

    pg_admin = PostgresqlHelpers::Postgresql.new(options)
    pg_admin.create_database(database)
    pg_admin.create_role(user, "fake_password")
    pg_admin.close

    db_admin = PostgresqlHelpers::Postgresql.new(options.merge(database: database))
    db_admin.create_tables
    db_admin.create_user_records
    db_admin.close
  end

  after do
    postgresql_client.close
  end
end
