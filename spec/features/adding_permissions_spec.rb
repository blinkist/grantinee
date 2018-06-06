# frozen_string_literal: true

require "spec_helper"
require "support/shared_contexts/mysql_database"
require "support/shared_contexts/postgresql_database"

RSpec.describe "Adding permissions" do
  context "when a permissions file exists with defined permissions" do
    subject { `grantinee -f Grantinee.test #{config}` }

    let(:database) { "grantinee_test" }
    let(:service) { "my_service" }

    let(:permissions) do
      %(
        on "#{database}" do
          # User on any host
          user :#{service} do
            select :users, [ :id, :anonymized ]
          end
        end
      )
    end

    before do
      IO.write("./Grantinee.test", permissions)

      # NOTE: mock script to use test file
      allow(Grantinee::Dsl).to receive(:eval).and_call_original
      allow(Grantinee::Dsl).to receive(:eval).with(File.read('Grantinee')) do
        Grantinee::Dsl.eval(File.read('Grantinee.test'))
      end
    end

    after { `rm ./Grantinee.test` }

    context "when defining permissions for mysql" do
      let(:config) { "-c spec/fixtures/config_mysql.yml" }

      include_context "mysql database"

      it "grants the service the defined privileges" do
        subject

        expect {
          mysql_client.query("SELECT id, anonymized FROM users;")
        }.not_to raise_error
      end

      it "denies the service any privilege that is not allowed" do
        subject

        expect {
          mysql_client.query("INSERT INTO users (id) VALUES ('malicious');")
        }.to raise_error(PG::InsufficientPrivilege)
      end      
    end

    context "when defining permissions for postgres" do
      let(:config) { "-c spec/fixtures/config_postgresql.yml" }

      include_context "postgresql database"

      it "grants the service the defined privileges" do
        subject

        expect {
          postgresql_client.exec("SELECT id, anonymized FROM users;")
        }.not_to raise_error
      end

      it "denies the service any privilege that is not allowed" do
        subject

        expect {
          postgresql_client.exec("INSERT INTO users(id) VALUES('malicious');")
        }.to raise_error(PG::InsufficientPrivilege)
      end
    end

    context "when defining permissions for mysql and postgres" do
      let(:engine) { %i[mysql postgresql] }

      # TODO
    end
  end
end