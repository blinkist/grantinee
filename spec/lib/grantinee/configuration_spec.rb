# frozen_string_literal: true

require "spec_helper"

module Grantinee
  RSpec.describe Configuration do
    let(:configuration) { described_class.new }

    describe "#url=" do
      subject { configuration.url = url }

      context "with a valid url" do
        let(:url) { "mysql2://superman:kryptonite@127.0.0.1:5432/database" }

        before { subject }

        it "parses the username from the url" do
          expect(configuration.username).to eq("superman")
        end

        it "parses the password from the url" do
          expect(configuration.password).to eq("kryptonite")
        end

        it "parses the hostname from the url" do
          expect(configuration.hostname).to eq("127.0.0.1")
        end

        it "parses the port from the url" do
          expect(configuration.port).to eq(5432)
        end

        it "parses the database from the url" do
          expect(configuration.database).to eq("database")
        end
      end

      context "with an invalid url" do
        let(:url) { "---------" }

        it "raises an error" do
          expect { subject }.to raise_error("Invalid database url")
        end
      end
    end
  end
end
