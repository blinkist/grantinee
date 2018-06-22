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

        let(:client) { double :mysql }

        before do
          allow(Grantinee).to receive(:configuration).and_return(grantinee_config)
          expect(Mysql2::Client).to receive(:new).with(db_params).and_return(client)
        end

        it "creates a connection to the database" do
          expect(subject.instance_variable_get(:@connection)).to eq client
        end
      end

      describe "#flush_privileges!" do
        subject { engine.flush_privileges! }
      end

      describe "#revoke_permissions!" do
        subject { engine.revoke_permissions!(data) }
      end

      describe "#grant_permission!" do
        subject { engine.grant_permission!(data) }
      end
    end
  end
end
