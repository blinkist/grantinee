# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"
require "./lib/grantinee/engine/mysql"
require "./lib/grantinee/engine/postgresql"

module Grantinee
  RSpec.describe Engine do
    let(:logger) { double debug: nil, info: nil }
    before { allow(Grantinee).to receive(:logger).and_return(logger) }

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

    end
  end
end
