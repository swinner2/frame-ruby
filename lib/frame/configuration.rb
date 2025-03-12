# frozen_string_literal: true

module Frame
  class Configuration
    DEFAULT_API_BASE = "https://api.framepayments.com"
    DEFAULT_OPEN_TIMEOUT = 30
    DEFAULT_READ_TIMEOUT = 80
    DEFAULT_VERIFY_SSL_CERTS = true

    attr_accessor :api_key, :api_base, :open_timeout, :read_timeout, :verify_ssl_certs, :log_level, :logger

    def self.setup
      new.tap do |config|
        config.api_base = DEFAULT_API_BASE
        config.open_timeout = DEFAULT_OPEN_TIMEOUT
        config.read_timeout = DEFAULT_READ_TIMEOUT
        config.verify_ssl_certs = DEFAULT_VERIFY_SSL_CERTS
        config.log_level = nil
        config.logger = nil
      end
    end
  end
end