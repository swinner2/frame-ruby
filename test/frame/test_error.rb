# frozen_string_literal: true

require "test_helper"

class TestError < Minitest::Test
  include FrameTest::Fixtures
  include FrameTest::APIOperations

  def test_authentication_error
    customer_id = "55435398-ec47-4bb4-ac9e-64031481cf48"
    
    # Stub an authentication error
    stub_request(:get, "#{Frame.api_base}/v1/customers/#{customer_id}")
      .with(headers: {"Authorization" => "Bearer #{TEST_API_KEY}"})
      .to_return(
        status: 401,
        body: JSON.generate({
          error: "Invalid API Key provided.",
          status: 401
        }),
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises Frame::AuthenticationError do
      Frame::Customer.retrieve(customer_id)
    end

    assert_equal 401, error.http_status
    assert_match(/Invalid API Key provided/, error.message)
  end

  def test_invalid_request_error
    # Stub an invalid request error
    stub_request(:post, "#{Frame.api_base}/v1/customers")
      .with(headers: {"Authorization" => "Bearer #{TEST_API_KEY}"})
      .to_return(
        status: 400,
        body: JSON.generate({
          error: "Missing required parameter: email",
          status: 400
        }),
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises Frame::InvalidRequestError do
      Frame::Customer.create(name: "John")
    end

    assert_equal 400, error.http_status
    assert_match(/Missing required parameter: email/, error.message)
  end

  def test_resource_not_found_error
    customer_id = "nonexistent_id"
    
    # Stub a not found error
    stub_request(:get, "#{Frame.api_base}/v1/customers/#{customer_id}")
      .with(headers: {"Authorization" => "Bearer #{TEST_API_KEY}"})
      .to_return(
        status: 404,
        body: JSON.generate({
          error: "Customer not found",
          status: 404
        }),
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises Frame::InvalidRequestError do
      Frame::Customer.retrieve(customer_id)
    end

    assert_equal 404, error.http_status
    assert_match(/Customer not found/, error.message)
  end

  def test_rate_limit_error
    # Stub a rate limit error
    stub_request(:get, "#{Frame.api_base}/v1/customers")
      .with(headers: {"Authorization" => "Bearer #{TEST_API_KEY}"})
      .to_return(
        status: 429,
        body: JSON.generate({
          error: "Rate limit exceeded",
          status: 429
        }),
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises Frame::RateLimitError do
      Frame::Customer.list
    end

    assert_equal 429, error.http_status
    assert_match(/Rate limit exceeded/, error.message)
  end

  def test_api_error
    # Stub a general API error
    stub_request(:get, "#{Frame.api_base}/v1/customers")
      .with(headers: {"Authorization" => "Bearer #{TEST_API_KEY}"})
      .to_return(
        status: 500,
        body: JSON.generate({
          error: "Internal server error",
          status: 500
        }),
        headers: { "Content-Type" => "application/json" }
      )

    error = assert_raises Frame::APIError do
      Frame::Customer.list
    end

    assert_equal 500, error.http_status
    assert_match(/Internal server error/, error.message)
  end
end