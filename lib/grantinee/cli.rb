module Grantinee
  class CLI

    attr_accessor :options
    attr_accessor :dsl
    attr_accessor :engine

    def initialize(args=ARGV, logger=::Logger.new($stderr))
      @args    = args
      @logger  = logger

      @options = {}
    end

    def run!
      parse_command_line_parameters
      process_command_line_parameters

      @dsl     = build_dsl
      @engine  = build_engine

      [ @dsl, @engine ]
    end


    private

    def parse_command_line_parameters
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: grantinee [options]"

        # Help
        opts.on(
          '-h', '--help',
          "Displays help"
        ) do
          puts opts
          exit
        end

        # Verbose mode
        opts.on(
          '-vLEVEL', '--verbosity=LEVEL',
          "Set verbosity level to debug, info, warn, error, fatal, or unknown (default: warning)"
        ) do |level|
          @options[:verbose] = level || 'warning'
        end

        # App boot file
        opts.on(
          '-rFILE', '--require=FILE',
          "Application boot file path (default: ./config/environment.rb)"
        ) do |file_path|
          @options[:require] = file_path
        end

        # Grantinee file
        opts.on(
          '-fFILE', '--file=FILE',
          "Permission definitions file path (default: ./Grantinee)"
        ) do |file_path|
          @options[:file] = file_path
        end

        # Database configuration file
        opts.on(
          '-cFILE', '--config=FILE',
          "Database configuration file path"
        ) do |file_path|
          @options[:config] = file_path
        end
      end

      parser.parse! @args
    end

    # Process parsed parameters
    def process_command_line_parameters
      # Application boot file
      if @options[:require]
        require @options[:require]
        Grantinee.detect_active_record_connection!
      elsif defined?(Rails)
        require './config/environment'
        Grantinee.detect_active_record_connection!
      end

      # Database configuration file
      if @options[:config]
        require options[:config]
      end

      # Grantinee file
      unless @options[:file]
        @options[:file] = "Grantinee"
      end

      # Explicit verbose mode, overrides configuration value
      if @options[:verbose]
        log_levels = %w{ debug info warn error fatal unknown }
        @logger.level = log_levels.index(@options[:verbose])
      end
    end

    def build_dsl
      Grantinee.logger = @logger
      Grantinee::Dsl.eval(File.read(@options[:file]))
    end

    def build_engine
      Grantinee::Engine.for Grantinee.configuration.engine
    end

  end
end
