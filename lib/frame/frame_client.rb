# frozen_string_literal: true

module Frame
  class FrameClient
    attr_accessor :conn, :config

    def self.active_client
      Thread.current[:frame_client] || default_client
    end

    def self.default_client
      @default_client ||= FrameClient.new(
        api_key: Frame.api_key,
        api_base: Frame.api_base,
        open_timeout: Frame.open_timeout,
        read_timeout: Frame.read_timeout,
        verify_ssl_certs: Frame.verify_ssl_certs
      )
    end

    def initialize(api_key: nil, api_base: nil, open_timeout: nil, read_timeout: nil, verify_ssl_certs: nil)
      @config = {
        api_key: api_key || Frame.api_key,
        api_base: api_base || Frame.api_base,
        open_timeout: open_timeout || Frame.open_timeout,
        read_timeout: read_timeout || Frame.read_timeout,
        verify_ssl_certs: verify_ssl_certs.nil? ? Frame.verify_ssl_certs : verify_ssl_certs
      }

      @conn = create_connection
    end

    def request(method, path, params = {}, opts = {})
      response = execute_request(method, path, params, opts)
      process_response(response)
    rescue Faraday::ConnectionFailed => e
      raise APIConnectionError.new("Connection failed: #{e.message}")
    rescue Faraday::TimeoutError => e
      raise APIConnectionError.new("Request timed out: #{e.message}")
    rescue Faraday::ClientError => e
      raise APIConnectionError.new("Client error: #{e.message}")
    end

    private

    def create_connection
      Faraday.new(url: @config[:api_base]) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter

        faraday.options.timeout = @config[:read_timeout]
        faraday.options.open_timeout = @config[:open_timeout]
      end
    end

    def execute_request(method, path, params, opts)
      headers = {
        "Authorization" => "Bearer #{@config[:api_key]}",
        "Content-Type" => "application/json",
        "User-Agent" => "FrameRuby/#{Frame::VERSION}"
      }

      case method.to_s.downcase.to_sym
      when :get
        @conn.get(path) do |req|
          req.params = params
          req.headers = headers
        end
      when :post
        @conn.post(path) do |req|
          req.body = params.to_json
          req.headers = headers
        end
      when :patch
        @conn.patch(path) do |req|
          req.body = params.to_json
          req.headers = headers
        end
      when :delete
        @conn.delete(path) do |req|
          req.params = params
          req.headers = headers
        end
      else
        raise APIConnectionError.new("Unrecognized HTTP method: #{method}")
      end
    end

    def process_response(response)
      case response.status
      when 200, 201, 202
        parsed_response = Util.symbolize_names(response.body)
      when 204
        parsed_response = {}
      when 400, 404
        error = Util.symbolize_names(response.body)
        raise InvalidRequestError.new(
          error[:error],
          http_status: response.status,
          http_body: response.body,
          json_body: error
        )
      when 401
        error = Util.symbolize_names(response.body)
        raise AuthenticationError.new(
          error[:error],
          http_status: response.status,
          http_body: response.body,
          json_body: error
        )
      when 429
        error = Util.symbolize_names(response.body)
        raise RateLimitError.new(
          error[:error],
          http_status: response.status,
          http_body: response.body,
          json_body: error
        )
      else
        error = Util.symbolize_names(response.body)
        raise APIError.new(
          error[:error] || "Unknown error",
          http_status: response.status,
          http_body: response.body,
          json_body: error
        )
      end

      parsed_response
    end
  end
end
