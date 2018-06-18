# frozen_string_literal: true

require 'uri'

module Grantinee
  class Configuration
    # Which engine is used by the library?
    attr_accessor :engine

    attr_accessor :logger

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
      @logger = ::Logger.new(nil)
    end

    def configured?
      username && password && hostname && port && database
    end

    # Handle url -> fields conversion
    def url=(url)
      uri = URI.parse url

      case uri.scheme
      when /^mysql/
        default_port = 3306
        @engine = :mysql
      when /^postgres/
        default_port = 5432
        @engine = :postgres
      end

      @username = uri.user
      @password = uri.password
      @hostname = uri.host
      @port     = uri.port || default_port
      @database = (uri.path || '').split('/').last
    end
  end
end
