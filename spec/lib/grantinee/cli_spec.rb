# frozen_string_literal: true

require "spec_helper"

module Grantinee
  RSpec.shared_examples "a Grantinee setup class" do
    it "returns three objects: DSL, engine and executor" do
      a_dsl, an_engine, an_executor = subject

      expect(a_dsl).to be_a_kind_of(Dsl)
      expect(an_engine).to be_a_kind_of(Engine::AbstractEngine)
      expect(an_executor).to be_a_kind_of(Executor)
    end
  end

  RSpec.describe CLI do
    describe "#run!" do
      subject { described_class.new(args).run! }

      context "in a non-rails context" do
        context "with no arguments" do
          let(:args) { [] }

          # TODO: raise a proper error message here, like: grantinee has not been
          # configured... it's missing x, y, z
          it "raises an error" do
            expect { subject }.to raise_error("Engine '' is not supported")
          end
        end

        context "with config arguments" do
          let(:args) { ["-c", config_file] }

          context "when the config file is present" do
            let(:config_file) { "./spec/fixtures/config_mysql.rb" }
            let(:executor) { Executor.new(nil, nil) }

            before do
              allow_any_instance_of(described_class).to receive(:build_executor)
                .and_return(executor)
              allow(executor).to receive(:run!)
            end

            context "when the config file is sane" do
              it_behaves_like "a Grantinee setup class"
            end
          end

          context "when the config file is not present" do
            let(:config_file) { "./mysteriously_missing_config.rb" }

            # TODO: raise custom error with nicer message?
            it "raises an error" do
              expect { subject }.to raise_error(LoadError)
            end
          end
        end
      end
    end
  end
end
