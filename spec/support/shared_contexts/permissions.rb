# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"

RSpec.shared_context "permissions" do
  let(:permissions_file) { defined?(super()) ? super() : "Grantinee.test" }
  let(:database) { defined?(super()) ? super() : "grantinee_test" }
  let(:user) { defined?(super()) ? super() : :dude }

  # NOTE: default permissions
  let(:permissions) do
    -> { select :users, %i[id anonymized] }
  end

  let(:permissions_code) do
    Permissions::Code.for(user, permissions, database: database)
  end
end
