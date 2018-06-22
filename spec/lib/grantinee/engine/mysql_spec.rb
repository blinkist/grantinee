# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"
require "./lib/grantinee/engine/mysql"
require "./lib/grantinee/engine/postgresql"

module Grantinee
  module Engine
    RSpec.describe Mysql do
      let(:logger) { double debug: nil, info: nil }
      before { allow(Grantinee).to receive(:logger).and_return(logger) }

      let(:engine) { described_class.new }
      let(:client) { double :mysql }

      before { allow(Mysql2::Client).to receive(:new).and_return(client) }

      describe "::new" do
        subject { engine }

        let(:db_params) do
          {
            username: "privileged_person",
            password: "secret",
            host:     "172.0.0.1",
            port:     5432,
            database: "grantinee_test"
          }
        end

        let(:grantinee_config) do
          double :grantinee_config,
                 username: "privileged_person",
                 password: "secret",
                 hostname: "172.0.0.1",
                 port: 5432,
                 database: "grantinee_test"
        end

        before do
          allow(Grantinee).to receive(:configuration).and_return(grantinee_config)
        end

        it "creates a connection to the database" do
          expect(Mysql2::Client).to receive(:new).with(db_params).and_return(client)
          expect(subject.instance_variable_get(:@connection)).to eq client
        end
      end

      describe "#flush_permissions!" do
        subject { engine.flush_permissions! }

        it "flushes the privileges for mysql" do
          expect(client).to receive(:query).with("FLUSH PRIVILEGES;")
          subject
        end
      end

      describe "#revoke_permissions!" do
        subject { engine.revoke_permissions!(data) }

        let(:data) do
          {
            user: "privileged_person",
            host: "high_horse",
            database: "bittersville"
          }
        end

        it "revokes all privileges for the user" do
          query = "REVOKE ALL PRIVILEGES ON `bittersville`.* FROM `privileged_person`@`high_horse`;"
          expect(client).to receive(:query).with(query)
          subject
        end
      end

      describe "#grant_permission!" do
        subject { engine.grant_permission!(data) }

        let(:data) do
          {
            user: "billy",
            host: "127.0.0.1",
            database: "country",
            table: "farm",
            kind: "SELECT",
            fields: [] # NOTE: we always assume fields is an array
          }
        end

        before { expect(client).to receive(:escape).with("SELECT").and_return("SELECT") }

        it "grants permissions for the specified data" do
          query = "GRANT SELECT ON `country`.`farm` TO `billy`@`127.0.0.1`;"
          expect(client).to receive(:query).with(query)
          subject
        end

        context "with fields data" do
          let(:data) { super().merge(fields: ["strawberries"]) }

          it "grants permissions for the specified data" do
            query = "GRANT SELECT(`strawberries`) ON `country`.`farm` TO `billy`@`127.0.0.1`;"
            expect(client).to receive(:query).with(query)
            subject
          end
        end
      end
    end
  end
end
