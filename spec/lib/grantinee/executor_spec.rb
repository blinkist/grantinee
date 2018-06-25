# frozen_string_literal: true

require "spec_helper"

module Grantinee
  RSpec.describe Executor do
    describe "#run!" do
      subject { described_class.new(dsl, engine).run! }

      let(:dsl) { double Dsl, permissions: permissions }
      let(:engine) do
        double Engine::AbstractEngine,
               revoke_permissions!: nil,
               grant_permission!: nil,
               flush_permissions!: nil
      end

      let(:permissions) { [permission_1, permission_2] }
      let(:permission_1) { double(:permission_1) }
      let(:permission_2) { double(:permission_2) }

      after { subject }

      it "revokes permissions from all permissions in the DSL" do
        expect(engine).to receive(:revoke_permissions!).with(permission_1)
        expect(engine).to receive(:revoke_permissions!).with(permission_2)
      end

      it "grants permissions for all permissions in the DSL" do
        expect(engine).to receive(:grant_permission!).with(permission_1)
        expect(engine).to receive(:grant_permission!).with(permission_2)
      end

      it "flushes the permissions" do
        expect(engine).to receive(:flush_permissions!).once
      end
    end
  end
end
