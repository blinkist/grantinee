# frozen_string_literal: true

require "spec_helper"
require "support/shared_contexts/mysql_database"
require "support/shared_contexts/postgresql_database"
require "support/shared_contexts/permissions"
require "support/query_helpers"

def db_error_args
  {
    mysql: [Mysql2::Error, /denied for user/],
    postgresql: [PG::InsufficientPrivilege]
  }
end

RSpec.describe "Adding permissions" do
  include QueryHelpers

  context "when a permissions file exists with defined permissions" do
    subject { `grantinee -f #{permissions_file} #{config}` }

    let(:user) { "my_user" }

    include_context "permissions"

    %i[mysql postgresql].each do |db_type|
      context "for #{db_type}" do
        let(:config) { "-c ./spec/fixtures/config_#{db_type}.rb" }
        let(:raised_error_args) { db_error_args[db_type] }

        include_context "#{db_type} database"

        before { subject }

        context "when the user can select all fields" do
          let(:permissions) do
            -> { select :users, %i[id anonymized] }
          end

          it "cannot insert records" do
            expect { query(db_type, :insert) }.to raise_error(*raised_error_args)
          end

          it "can select records" do
            expect { query(db_type, :select) }.not_to raise_error
          end

          it "cannot update records" do
            expect { query(db_type, :update) }.to raise_error(*raised_error_args)
          end

          it "cannot delete records" do
            expect { query(db_type, :delete) }.to raise_error(*raised_error_args)
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
            expect { query(db_type, :select) }.to raise_error(*raised_error_args)
          end

          it "cannot update records" do
            expect { query(db_type, :update) }.to raise_error(*raised_error_args)
          end

          it "cannot delete records" do
            expect { query(db_type, :delete) }.to raise_error(*raised_error_args)
          end
        end

        context "when the user can update records in a table" do
          let(:permissions) do
            -> { update :users }
          end

          it "cannot insert records" do
            expect { query(db_type, :insert) }.to raise_error(*raised_error_args)
          end

          it "cannot select records" do
            expect { query(db_type, :select) }.to raise_error(*raised_error_args)
          end

          it "can update records" do
            expect { query(db_type, :update) }.not_to raise_error
          end

          it "cannot delete records" do
            expect { query(db_type, :delete) }.to raise_error(*raised_error_args)
          end
        end

        # TODO: delete records
        context "when the user can delete records from a table" do
          let(:permissions) do
            -> { delete :users }
          end

          xit "cannot insert records" do
            expect { query(db_type, :insert) }.to raise_error(*raised_error_args)
          end

          xit "cannot select records" do
            expect { query(db_type, :select) }.to raise_error(*raised_error_args)
          end

          xit "cannot update records" do
            expect { query(db_type, :update) }.to raise_error(*raised_error_args)
          end

          xit "can delete records" do
            expect { query(db_type, :delete) }.not_to raise_error
          end
        end

        context "when the user can do all for a table" do
          let(:permissions) do
            -> { all :users }
          end

          it "can insert records" do
            expect { query(db_type, :insert) }.not_to raise_error
          end

          it "can select records" do
            expect { query(db_type, :select) }.not_to raise_error
          end

          it "can update records" do
            expect { query(db_type, :update) }.not_to raise_error
          end

          it "can delete records" do
            expect { query(db_type, :delete) }.not_to raise_error
          end
        end
      end
    end
  end
end
