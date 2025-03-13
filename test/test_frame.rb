# frozen_string_literal: true

require "test_helper"

class TestFrame < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Frame::VERSION
  end

  def test_api_key_configuration
    original_api_key = Frame.api_key
    begin
      Frame.api_key = "test_api_key"
      assert_equal "test_api_key", Frame.api_key
    ensure
      Frame.api_key = original_api_key
    end
  end

  def test_api_base_configuration
    original_api_base = Frame.api_base
    begin
      Frame.api_base = "https://test.framepayments.com"
      assert_equal "https://test.framepayments.com", Frame.api_base
    ensure
      Frame.api_base = original_api_base
    end
  end

  def test_timeout_configuration
    original_open_timeout = Frame.open_timeout
    original_read_timeout = Frame.read_timeout
    begin
      Frame.open_timeout = 10
      Frame.read_timeout = 20
      assert_equal 10, Frame.open_timeout
      assert_equal 20, Frame.read_timeout
    ensure
      Frame.open_timeout = original_open_timeout
      Frame.read_timeout = original_read_timeout
    end
  end
end
