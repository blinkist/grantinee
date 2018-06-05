# frozen_string_literal: true

require "spec_helper"
require "grantinee/engine/postgresql"
require "pg"

require "support/shared_contexts/postgresql_database"

RSpec.describe "Adding permissions" do
  context "when a permissions file exists with defined permissions" do
    subject { Grantinee::Dsl.eval(File.read('./Grantinee.test')) }

    let(:database) { "grantinee_client_test" }
    let(:service) { "my_service" }

    let(:permissions) do
      %(
        on "#{database}", :#{engine} do
          # User on any host
          user :#{service} do
            select :users, [ :id, :anonymized ]
            select :lists_users
          end
        end
      )
    end

    before { IO.write("./Grantinee.test", permissions) }
    after { `rm ./Grantinee.test` }

    context "when defining permissions for mysql" do
      let(:engine) { :mysql }

      # TODO
    end

    context "when defining permissions for postgres" do
      let(:engine) { :postgresql }

      include_context "postgresql database"

      it "grants the service the defined privileges" do
        # subject

        expect {
          postgresql_client.exec("SELECT id, anonymized FROM users;")
        }.not_to raise_error
      end

      it "denies the service any privilege that is not allowed" do
        # subject

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
