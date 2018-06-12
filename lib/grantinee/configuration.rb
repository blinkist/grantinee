# frozen_string_literal: true

require 'uri'

module Grantinee
  class Configuration
    SUPPORTED_ENGINES = %w[mysql postgresql].freeze

    # Which engine is used by the library?
    attr_accessor :engine

    # Connection parameters
    attr_accessor :username
    attr_accessor :password
    attr_accessor :hostname
    attr_accessor :port
    attr_accessor :database
    attr_reader :url

    # Allow verbose mode
    attr_accessor :verbose

    def initialize
      # Do nothing...
    end

    def configured?
      self.username &&
        self.password &&
        self.hostname &&
        self.port &&
        self.database
    end

    # Handle url -> fields conversion
    def url=(url)
      uri = begin
        URI.parse url
      rescue URI::InvalidURIError
        raise 'Invalid database url'
      end

      @username = uri.user
      @password = uri.password
      @hostname = uri.host
      @port     = uri.port
      @database = (uri.path || '').split('/').last
    end
  end
end
