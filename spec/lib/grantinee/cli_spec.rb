# frozen_string_literal: true

require "spec_helper"
require "byebug"

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
      subject { described_class.new(args, fake_logger).run! }

      let(:executor) { Executor.new(nil, nil) }
      let(:fake_logger) { double ::Logger, debug: nil, info: nil, warn: nil }
      let(:default_args) { ["-c", config_file] }
      let(:config_file) { "./spec/fixtures/config_mysql.rb" }

      before do
        allow_any_instance_of(described_class).to receive(:build_executor)
          .and_return(executor)
        allow(executor).to receive(:run!)
      end

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

        context "with the help argument" do
          let(:args) { ["-h"] }

          it "exits the program" do
            expect { subject }.to raise_error SystemExit
          end

          context "when running" do
            after do
              begin
                subject
              rescue SystemExit
              end
            end

            it "does not do anything with a dsl" do
              expect_any_instance_of(CLI).to_not receive(:build_dsl)
            end

            it "does not do anything with an engine" do
              expect_any_instance_of(CLI).to_not receive(:build_engine)
            end

            it "does not do anything with an executor" do
              expect_any_instance_of(CLI).to_not receive(:build_executor)
            end

            it "does not run any executor" do
              expect_any_instance_of(Executor).to_not receive(:run!)
            end
          end
        end

        context "with the verbosity argument" do
          let(:args) { default_args << ["-v"] }

          def log_level(name)
            %w[debug info warn error fatal].index(name)
          end

          context "with no -v option passed" do
            before { expect(fake_logger).to_not receive(:level=) }

            it_behaves_like "a Grantinee setup class"
          end

          %w[debug info warn error fatal].each do |level|
            context "with a -v #{level} option passed" do
              let(:args) { ["-v", level] }

              it "sets the logger level to #{level}" do
                expect(fake_logger).to receive(:level=).with(log_level(level))
                subject
              end
            end
          end
        end

        context "with the require (application booth path) argument" do
          let(:args) { ["-r"] }

          # TODO
        end

        context "with the premissions file path argument" do
          let(:args) { ["-f"] }

          # TODO
        end
      end
    end
  end
end
