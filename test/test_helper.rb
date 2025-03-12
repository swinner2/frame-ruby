# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "frame"
require "minitest/autorun"
require "minitest/pride"
require "webmock/minitest"
require "json"
require "stringio"
require "byebug"
# Test API key
TEST_API_KEY = "frame_test_key"

module FrameTest
  module Fixtures
    def fixture_path(path)
      File.join(File.dirname(__FILE__), "fixtures", path)
    end

    def fixture(path)
      File.read(fixture_path(path))
    end

    def json_fixture(path)
      JSON.parse(fixture(path), symbolize_names: true)
    end
  end

  module APIOperations
    def stub_api_request(method, path, response_fixture, status: 200, request_params: nil)
      url = "#{Frame.api_base}#{path}"
      
      stub_params = {
        headers: {
          "Authorization" => "Bearer #{TEST_API_KEY}",
          "Content-Type" => "application/json"
        }
      }
      
      # Add query parameters for GET requests if provided
      if method == :get && request_params
        stub_params[:query] = request_params
      end
      
      stub_request(method, url)
        .with(stub_params)
        .to_return(
          body: fixture(response_fixture),
          status: status,
          headers: { "Content-Type" => "application/json" }
        )
    end
  end
end

# Configure Frame for testing
Frame.api_key = TEST_API_KEY
Frame.api_base = "https://api.framepayments.com"
