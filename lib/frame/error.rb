# frozen_string_literal: true

module Frame
  # Base error class for all Frame-related errors
  class Error < StandardError; end

  # API Error class for handling API responses
  class APIError < Error
    attr_reader :message
    attr_reader :http_status
    attr_reader :http_body
    attr_reader :json_body
    attr_reader :code

    def initialize(message = nil, http_status: nil, http_body: nil, json_body: nil, code: nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @json_body = json_body
      @code = code
      super(message)
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      code_string = @code.nil? ? "" : "(Code #{@code}) "
      "#{status_string}#{code_string}#{@message}"
    end
  end

  # Authentication error
  class AuthenticationError < APIError; end

  # Invalid request error
  class InvalidRequestError < APIError; end

  # API connection error
  class APIConnectionError < APIError; end

  # Rate limit error
  class RateLimitError < APIError; end

  # Resource not found error
  class ResourceNotFoundError < APIError; end

  # Invalid parameters error
  class InvalidParameterError < APIError; end
end