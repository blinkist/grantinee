# frozen_string_literal: true

require "spec_helper"
require "support/shared_contexts/mysql_database"
require "support/shared_contexts/postgresql_database"
require "support/shared_contexts/permissions"

RSpec.describe "Adding permissions" do
  context "when a permissions file exists with defined permissions" do
    subject { `grantinee -f #{permissions_file} #{config}` }

    let(:user) { "my_user" }

    include_context "permissions"

    context "for mysql" do
      let(:config) { "-c spec/fixtures/config_mysql.yml" }

      include_context "mysql database"

      it "grants the user the defined privileges" do
        subject

        expect {
          mysql_client.query("SELECT id, anonymized FROM users;")
        }.not_to raise_error
      end

      it "denies the user any privilege that is not allowed" do
        subject

        expect {
          mysql_client.query("INSERT INTO users (id) VALUES ('malicious');")
        }.to raise_error(Mysql2::Error)
      end
    end

    context "for postgres" do
      let(:config) { "-c spec/fixtures/config_postgresql.yml" }

      include_context "postgresql database"

      context "when the user can select all fields" do
        let(:permissions) do
          -> { select :users, [ :id, :anonymized ] }
        end

        it "grants the user the defined privileges" do
          subject

          expect {
            postgresql_client.exec("SELECT id, anonymized FROM users;")
          }.not_to raise_error
        end

        it "denies the user any privilege that is not allowed" do
          subject

          expect {
            postgresql_client.exec("INSERT INTO users(id) VALUES('malicious');")
          }.to raise_error(PG::InsufficientPrivilege)
        end
      end

      context "when the user can create records for a table" do
        let(:permissions) do
          -> { insert :users }
        end

        before { subject }

        it "can create records" do
          expect {
            postgresql_client.exec("INSERT INTO users(id) VALUES('just_doing_me');")
          }.not_to raise_error
        end

        it "cannot select records" do
          expect {
            postgresql_client.exec("SELECT id, anonymized FROM users;")
          }.to raise_error(PG::InsufficientPrivilege)
        end

        it "cannot update records" do
          expect {
            postgresql_client.exec("UPDATE users SET anonymized = true;")
          }.to raise_error(PG::InsufficientPrivilege)
        end

        it "cannot delete records" do
          expect {
            postgresql_client.exec("DELETE FROM users;")
          }.to raise_error(PG::InsufficientPrivilege)
        end
      end
    end
  end
end
