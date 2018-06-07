# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"

RSpec.shared_context "permissions" do
  let(:permissions_file) { defined?(super()) ? super() : "Grantinee.test" }
  let(:database) { defined?(super()) ? super() : "grantinee_test"  }
  let(:user) { defined?(super()) ? super() : :dude }

  let(:permissions) do
    Permissions::Code.for(user, database: database) do
      select :users, [ :id, :anonymized ]
    end
  end

  before do
    IO.write("./#{permissions_file}", permissions)

    # NOTE: mock script to use test file
    allow(Grantinee::Dsl).to receive(:eval).and_call_original
    allow(Grantinee::Dsl).to receive(:eval).with(File.read('Grantinee')) do
      Grantinee::Dsl.new(permissions)
    end
  end

  after { `rm ./#{permissions_file}` }
end
