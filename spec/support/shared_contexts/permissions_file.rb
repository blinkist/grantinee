# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"

RSpec.shared_context "permissions file" do
  let(:permissions_file) { defined?(super()) ? super() : "Grantinee.test" }
  let(:database) { defined?(super()) ? super() : "grantinee_test" }
  let(:users) { defined?(super()) ? super() : ["dude"] }

  # NOTE: default permissions
  let(:permissions) do
    [-> { select :users, %i[id anonymized] }]
  end

  let(:permissions_code) do
    Permissions::Code.for(users, permissions, database: database)
  end

  before { IO.write("./#{permissions_file}", permissions_code) }
  after { `rm ./#{permissions_file}` }
end
