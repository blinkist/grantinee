# frozen_string_literal: true

require "spec_helper"
require "support/permissions_helpers"

RSpec.shared_context "permissions" do
  let(:permissions_file) { defined?(super()) ? super() : "Grantinee.test" }
  let(:database) { defined?(super()) ? super() : "grantinee_test" }
  let(:users) { defined?(super()) ? super() : %w[dude dudette] }

  # NOTE: default permissions
  let(:permissions) do
    lambdas = []
    lambdas.push(
      -> { select :users, %i[id anonymized] }
    )
    lambdas.push(
      -> { select :users, %i[id anonymized email.primary] }
    )
    lambdas
  end

  let(:permissions_code) do
    Permissions::Code.for(users, permissions, database: database)
  end
end
