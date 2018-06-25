# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"
require "./lib/grantinee/engine/mysql"
require "./lib/grantinee/engine/postgresql"

def reset_grantinee_configuration!
  Grantinee.configuration.username = nil
  Grantinee.configuration.password = nil
  Grantinee.configuration.hostname = nil
  Grantinee.configuration.port = nil
  Grantinee.configuration.database = nil

  Grantinee.configuration.engine = nil
end

module Grantinee
  RSpec.describe Engine do
    let(:logger) { double debug: nil, info: nil }

    before { allow(Grantinee).to receive(:logger).and_return(logger) }

    after { reset_grantinee_configuration! }

    describe "::for" do
      subject { described_class.for(engine) }

      context "when passed an unsupported engine" do
        let(:engine) { "oracle" }

        # TODO: proper error class?
        it "raises an error" do
          expect { subject }.to raise_error(/Engine 'oracle' is not supported/)
        end
      end

      context "when passed a supported engine" do
        context "mysql" do
          let(:engine) { "mysql" }
          let(:mysql_instance) { double Engine::Mysql }

          before { allow(Engine::Mysql).to receive(:new).and_return(mysql_instance) }

          it { is_expected.to eq mysql_instance }
        end

        context "postgresql" do
          let(:engine) { "postgresql" }
          let(:postgresql_instance) { double Engine::Postgresql }

          before { allow(Engine::Postgresql).to receive(:new).and_return(postgresql_instance) }

          it { is_expected.to eq postgresql_instance }
        end
      end
    end

    describe "::detect_active_record_connection!" do
      subject { described_class.detect_active_record_connection! }

      context "when ActiveRecord is present" do
        let(:ar_config) { {} }
        let(:active_record) { Class.new }
        let!(:og_grantinee_configuration) { Grantinee.configuration }

        before do
          stub_const("ActiveRecord::Base", active_record)
          allow(active_record).to receive(:connection_config).and_return(ar_config)
        end

        context "and there is an ar_config" do
          let(:adapter) { :mysql }
          let(:ar_config) do
            {
              adapter: adapter.to_s,
              username: "db_user",
              password: "db_secret",
              host: "db_host",
              port: 0_001,
              database: "db_database"
            }
          end

          it "sets the grantinee configuration to the ar_config" do
            subject

            expect(Grantinee.configuration.username).to eq(ar_config[:username])
            expect(Grantinee.configuration.password).to eq(ar_config[:password])
            expect(Grantinee.configuration.hostname).to eq(ar_config[:host])
            expect(Grantinee.configuration.port).to eq(ar_config[:port])
            expect(Grantinee.configuration.database).to eq(ar_config[:database])
          end

          it "sets the grantinee engine to the specified engine" do
            subject

            expect(Grantinee.configuration.engine).to eq(adapter.to_sym)
          end
        end
      end

      context "when ActiveRecord is not present" do
        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end

        it "does nothing to the configuration" do
          subject

          expect(Grantinee.configuration.username).to be_nil
          expect(Grantinee.configuration.password).to be_nil
          expect(Grantinee.configuration.hostname).to be_nil
          expect(Grantinee.configuration.port).to be_nil
          expect(Grantinee.configuration.database).to be_nil
        end
      end
    end
  end
end
