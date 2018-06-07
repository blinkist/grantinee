# frozen_string_literal: true

require "spec_helper"
require "support/shared_contexts/mysql_database"
require "support/shared_contexts/postgresql_database"
require "support/shared_contexts/permissions"
require "support/query_helpers"

RSpec.describe "Adding permissions" do
  include QueryHelpers

  context "when a permissions file exists with defined permissions" do
    subject { `grantinee -f #{permissions_file} #{config}` }

    let(:user) { "my_user" }

    include_context "permissions"

    context "for mysql" do
      let(:config) { "-c spec/fixtures/config_mysql.yml" }

      include_context "mysql database"

      before { subject }

      it "grants the user the defined privileges" do
        expect { query(db_type, :select) }.not_to raise_error
      end

      it "denies the user any privilege that is not allowed" do
        expect { query(db_type, :insert) }.to raise_error(Mysql2::Error)
      end
    end

    context "for postgres" do
      let(:config) { "-c spec/fixtures/config_postgresql.yml" }

      include_context "postgresql database"

      before { subject }

      context "when the user can select all fields" do
        let(:permissions) do
          -> { select :users, [ :id, :anonymized ] }
        end

        it "cannot insert records" do
          expect { query(db_type, :insert) }.to raise_error(PG::InsufficientPrivilege)
        end

        it "can select records" do
          expect { query(db_type, :select) }.not_to raise_error
        end

        it "cannot update records" do
          expect { query(db_type, :update) }.to raise_error(PG::InsufficientPrivilege)
        end

        it "cannot delete records" do
          expect { query(db_type, :delete) }.to raise_error(PG::InsufficientPrivilege)
        end
      end

      context "when the user can insert records for a table" do
        let(:permissions) do
          -> { insert :users }
        end

        it "can insert records" do
          expect { query(db_type, :insert) }.not_to raise_error
        end

        it "cannot select records" do
          expect { query(db_type, :select) }.to raise_error(PG::InsufficientPrivilege)
        end

        it "cannot update records" do
          expect { query(db_type, :update) }.to raise_error(PG::InsufficientPrivilege)
        end

        it "cannot delete records" do
          expect { query(db_type, :delete) }.to raise_error(PG::InsufficientPrivilege)
        end
      end
    end
  end
end
