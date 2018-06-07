# frozen_string_literal: true

require "spec_helper"
require "support/shared_contexts/mysql_database"
require "support/shared_contexts/postgresql_database"

RSpec.describe "Adding permissions" do
  context "when a permissions file exists with defined permissions" do
    subject { `grantinee -f #{permissions_file} #{config}` }

    let(:database) { "grantinee_test" }
    let(:user) { "my_user" }
    let(:permissions_file) { "Grantinee.test" }

    # TODO: make small DSL that let's you define permissions for each context
    # Think: https://github.com/blinkist/blinkist-watchman/blob/develop/spec/support/authorized_request.rb#L68
    # https://github.com/blinkist/blinkist-watchman/blob/develop/spec/support/shared_examples/a_permissioned_resource.rb#L7
    let(:permissions) do
      %(
        on "#{database}" do
          # User on any host
          user :#{user} do
            select :users, [ :id, :anonymized ]
          end
        end
      )
    end

    before do
      IO.write("./#{permissions_file}", permissions)

      # NOTE: mock script to use test file
      allow(Grantinee::Dsl).to receive(:eval).and_call_original
      allow(Grantinee::Dsl).to receive(:eval).with(File.read('Grantinee')) do
        Grantinee::Dsl.eval(File.read(permissions_file))
      end
    end

    after { `rm ./#{permissions_file}` }

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
          %(
            on "#{database}" do
              # User on any host
              user :#{user} do
                select :users, [ :id, :anonymized ]
              end
            end
          )
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
          %(
            on "#{database}" do
              # User on any host
              user :#{user} do
                insert :users, [ :id, :anonymized ]
              end
            end
          )
        end

        it "grants the user the defined privileges" do
          subject

          expect {
            postgresql_client.exec("INSERT INTO users(id) VALUES('just_doing_me');")
          }.not_to raise_error
        end

        it "denies the user any privilege that is not allowed" do
          subject

          expect {
            postgresql_client.exec("SELECT id, anonymized FROM users;")
          }.to raise_error(PG::InsufficientPrivilege)
        end
      end
    end

    context "when defining permissions for mysql and postgres" do
      let(:engine) { %i[mysql postgresql] }

      # TODO
    end
  end
end
