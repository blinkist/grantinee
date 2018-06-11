# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"

module Grantinee
  RSpec.describe Dsl do
    describe "::new" do
      subject { described_class.eval(permissions_code) }

      let(:permissions_code) do
        Permissions::Code.for("user") do
          select :users, [:id]
        end
      end

      # NOTE: mock the logger
      let(:logger) { double debug: nil, info: nil }

      let(:db_data) { { user: "user", host: "%", database: "grantinee_test" } }
      let(:permissions_data) do
        [
          {
            database: "grantinee_test",
            user: "user",
            host: "%",
            kind: "select",
            table: :users,
            fields: [:id]
          }
        ]
      end

      before { allow(Grantinee).to receive(:logger).and_return(logger) }

      # Obviously...
      it { is_expected.to be_an_instance_of Grantinee::Dsl }

      it "sets the Grantinee data" do
        expect(subject.instance_variable_get(:@data)).to eq(db_data)
      end

      it "sets the Grantinee permissions data" do
        expect(subject.instance_variable_get(:@permissions)).to eq(permissions_data)
      end
    end
  end
end
