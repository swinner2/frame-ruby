# frozen_string_literal: true

require "test_helper"

class TestListObject < Minitest::Test
  include FrameTest::Fixtures
  include FrameTest::APIOperations

  def test_list_object_initialization
    list_data = json_fixture("customers_list.json")
    list = Frame::ListObject.construct_from(list_data)
    
    assert_equal 2, list.data.size
    assert_equal false, list.has_more?
    assert_equal 1, list.instance_variable_get(:@page)
  end

  def test_list_object_enumerable
    list_data = json_fixture("customers_list.json")
    list = Frame::ListObject.construct_from(list_data)
    
    # Test Enumerable interface
    assert_equal 2, list.count
    assert list.first.is_a?(Frame::Customer), "Expected first item to be a Customer object"
    assert list.last.is_a?(Frame::Customer), "Expected last item to be a Customer object"
    assert_equal "John", list.first.name
    assert_equal "Jane", list.last.name

    # Test map method
    names = list.map(&:name)
    assert_equal ["John", "Jane"], names
  end

  def test_list_object_to_hash
    list_data = json_fixture("customers_list.json")
    list = Frame::ListObject.construct_from(list_data)
    
    hash = list.to_hash
    assert_equal Hash, hash.class
    assert_equal Array, hash[:data].class
    assert_equal 2, hash[:data].size
    assert_equal Hash, hash[:meta].class
    assert_equal false, hash[:meta][:has_more]
  end

  def test_list_pagination_with_has_more
    # Create a custom fixture with has_more = true
    list_data = json_fixture("customers_list.json")
    list_data[:meta][:has_more] = true
    
    list = Frame::ListObject.construct_from(list_data)
    assert_equal true, list.has_more?
    
    # Stub the next page request
    stub_request(:get, "#{Frame.api_base}/v1/customers")
      .with(
        query: { page: 2 },
        headers: { "Authorization" => "Bearer #{TEST_API_KEY}" }
      )
      .to_return(
        status: 200,
        body: fixture("customers_list.json"),
        headers: { "Content-Type" => "application/json" }
      )
    
    next_page = list.next_page
    
    assert_instance_of Frame::ListObject, next_page
    assert_equal 2, next_page.data.size
    
    # Verify the request was made with correct pagination parameters
    assert_requested :get, "#{Frame.api_base}/v1/customers", 
                     query: { page: 2 },
                     times: 1
  end

  def test_list_pagination_without_has_more
    list_data = json_fixture("customers_list.json")
    list = Frame::ListObject.construct_from(list_data)
    
    assert_equal false, list.has_more?
    
    # Next page should return an empty list when has_more is false
    next_page = list.next_page
    
    assert_instance_of Frame::ListObject, next_page
    assert_equal 0, next_page.data.size
    
    # Verify no request was made
    assert_not_requested :get, "#{Frame.api_base}/v1/customers"
  end

  def test_list_with_filters
    # Create a list with filters
    list_data = json_fixture("customers_list.json")
    list = Frame::ListObject.construct_from(list_data)
    list.filters = { email: "john@example.com" }
    
    # Stub the next page request with the filters
    stub_request(:get, "#{Frame.api_base}/v1/customers")
      .with(
        query: { page: 2, email: "john@example.com" },
        headers: { "Authorization" => "Bearer #{TEST_API_KEY}" }
      )
      .to_return(
        status: 200,
        body: fixture("customers_list.json"),
        headers: { "Content-Type" => "application/json" }
      )
    
    # Force a pagination request even though has_more is false
    list.instance_variable_set(:@has_more, true)
    list.next_page
    
    # Verify the request was made with both pagination and filter parameters
    assert_requested :get, "#{Frame.api_base}/v1/customers", 
                     query: { page: 2, email: "john@example.com" },
                     times: 1
  end
end