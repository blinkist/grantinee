# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"
require "./lib/grantinee/engine/postgresql"

module Grantinee
  module Engine
    RSpec.describe Postgresql do
      let(:logger) { double debug: nil, info: nil }
      before { allow(Grantinee).to receive(:logger).and_return(logger) }

      let(:engine) { described_class.new }
      let(:client) { double :postgresl }

      before { allow(PG::Connection).to receive(:open).and_return(client) }

      describe "::new" do
        subject { engine }

        let(:db_params) do
          {
            user: "privileged_person",
            password: "secret",
            host:     "172.0.0.1",
            port:     5432,
            dbname: "grantinee_test"
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
          expect(PG::Connection).to receive(:open).with(db_params).and_return(client)
          expect(subject.instance_variable_get(:@connection)).to eq client
        end
      end

      describe "#flush_permissions!" do
        subject { engine.flush_permissions! }

        it "does not execute a query with the client" do
          expect(client).not_to receive(:exec)
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

        before do
          expect(client).to receive(:escape_string) do |string|
            string
          end
        end

        it "revokes all privileges for the user" do
          query = "REVOKE ALL PRIVILEGES ON DATABASE bittersville FROM privileged_person;"
          expect(client).to receive(:exec).with(query)
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

        before do
          expect(client).to receive(:escape_string) do |string|
            string
          end.at_least(1).times
        end

        it "grants permissions for the specified data" do
          query = "GRANT SELECT ON farm TO billy;"
          expect(client).to receive(:exec).with(query)
          subject
        end

        context "with fields data" do
          let(:data) { super().merge(fields: ["strawberries"]) }

          it "grants permissions for the specified data" do
            query = "GRANT SELECT(strawberries) ON TABLE farm TO billy;"
            expect(client).to receive(:exec).with(query)
            subject
          end
        end
      end
    end
  end
end
