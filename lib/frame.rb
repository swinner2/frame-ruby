# frozen_string_literal: true

require "json"
require "logger"
require "uri"
require "cgi"
require "forwardable"
require "faraday"

require "frame/version"
require "frame/error"

# API operations
require "frame/api_operations/create"
require "frame/api_operations/delete"
require "frame/api_operations/list"
require "frame/api_operations/request"
require "frame/api_operations/save"

# Resources
require "frame/util"
require "frame/configuration"
require "frame/frame_client"
require "frame/frame_object"
require "frame/list_object"
require "frame/api_resource"

# Named API resources
require "frame/resources/customer"

module Frame
  @config = Configuration.setup

  class << self
    extend Forwardable

    attr_reader :config

    def_delegators :@config, :api_key, :api_key=
    def_delegators :@config, :api_base, :api_base=
    def_delegators :@config, :open_timeout, :open_timeout=
    def_delegators :@config, :read_timeout, :read_timeout=
    def_delegators :@config, :verify_ssl_certs, :verify_ssl_certs=
    def_delegators :@config, :log_level, :log_level=
    def_delegators :@config, :logger, :logger=
  end
end
