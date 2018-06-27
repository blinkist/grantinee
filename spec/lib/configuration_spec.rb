# frozen_string_literal: true

require "spec_helper"

module Grantinee
  RSpec.describe Configuration do
    let(:instance) { described_class.new }

    describe "configuration via URL" do
      context "for mysql" do
        before { instance.url = "mysql2://root:mysql@127.0.0.1/grantinee-test?some=1&option=2" }

        describe "engine" do
          subject { instance.engine }

          it { is_expected.to eq(:mysql) }
        end

        describe "username" do
          subject { instance.username }

          it { is_expected.to eq('root') }
        end

        describe "password" do
          subject { instance.password }

          it { is_expected.to eq('mysql') }
        end

        describe "hostname" do
          subject { instance.hostname }

          it { is_expected.to eq('127.0.0.1') }
        end

        describe "port" do
          subject { instance.port }

          it { is_expected.to eq(3306) }
        end

        describe "database" do
          subject { instance.database }

          it { is_expected.to eq('grantinee-test') }
        end
      end
    end
  end
end
