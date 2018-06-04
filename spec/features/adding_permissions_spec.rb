# frozen_string_literal: true

require "spec_helper"
require "grantinee/engine/postgresql"
require "pg"

RSpec.describe "Adding permissions" do
  context "when a permissions file exists with defined permissions" do
    let(:database) { "grantinee_client_test" }
    let(:service) { "my_service" }

    let(:permissions) do
      %(
        Grantinee.on "#{database}", engine: :#{engine} do
          # User on any host
          user :#{service} do
            select :users, [ :id, :anonymized ]
            select :lists_users
          end
        end
      )
    end

    before { IO.write("./permissions.rb", permissions) }
    after { `rm ./permissions.rb` }

    context "when defining permissions for mysql" do
      let(:engine) { :mysql }

      # TODO
    end

    context "when defining permissions for postgres" do
      let(:engine) { :postgresql }

      # A root engine to create/drop the database
      let(:pgsql_no_db_admin) do
        PG::Connection.open(
          user:     nil,
          password: nil,
          host:     Grantinee.config.dig(:postgresql, :hostname),
          port:     Grantinee.config.dig(:postgresql, :port)
        )
      end

      # A root engine that we can manipulate the database with
      let(:pgsql_admin) do
        PG::Connection.open(
          user:     nil,
          password: nil,
          host:     Grantinee.config.dig(:postgresql, :hostname),
          port:     Grantinee.config.dig(:postgresql, :port),
          dbname:   database
        )
      end

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
        pgsql_no_db_admin.exec "CREATE DATABASE #{database};"

        pgsql_admin.exec "CREATE ROLE #{service} NOINHERIT LOGIN PASSWORD 'fake_password';"
        pgsql_admin.exec "DROP TABLE IF EXISTS users;"
        pgsql_admin.exec "CREATE TABLE users(id VARCHAR(30) PRIMARY KEY, anonymized boolean);"
        pgsql_admin.exec "INSERT INTO users(id, anonymized) VALUES('12345e6', false);"
      end

      after do
        postgresql_client.close

        pgsql_admin.exec "DROP TABLE IF EXISTS users;"
        pgsql_admin.exec "DROP ROLE #{service};"
        pgsql_admin.close

        pgsql_no_db_admin.exec "DROP DATABASE #{database};"
        pgsql_no_db_admin.close
      end

      it "grants the service the defined privileges" do
        expect {
          postgresql_client.exec("SELECT id, anonymized FROM users;")
        }.not_to raise_error
      end

      it "denies the service any privilege that is not allowed" do
        expect {
          postgresql_client.exec("SELECT * FROM users;")
        }.to raise_error(PG::InsufficientPrivilege)
      end
    end

    context "when defining permissions for mysql and postgres" do
      let(:engine) { %i[mysql postgresql] }

      # TODO
    end
  end
end
