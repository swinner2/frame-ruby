# frozen_string_literal: true

require "test_helper"

class TestCustomer < Minitest::Test
  include FrameTest::Fixtures
  include FrameTest::APIOperations

  def test_retrieve_customer
    customer_id = "55435398-ec47-4bb4-ac9e-64031481cf48"
    stub_api_request(
      :get,
      "/v1/customers/#{customer_id}",
      "customer.json"
    )

    customer = Frame::Customer.retrieve(customer_id)
    assert_equal customer_id, customer.id
    assert_equal "John", customer.name
    assert_equal "john@example.com", customer.email
    assert_equal "customer", customer.object
    assert_equal "active", customer.status
  end

  def test_create_customer
    stub_api_request(
      :post,
      "/v1/customers",
      "customer.json"
    )

    customer = Frame::Customer.create(
      name: "John",
      email: "john@example.com"
    )

    assert_equal "55435398-ec47-4bb4-ac9e-64031481cf48", customer.id
    assert_equal "John", customer.name
    assert_equal "john@example.com", customer.email
    assert_equal "customer", customer.object
  end

  def test_update_customer
    customer_id = "55435398-ec47-4bb4-ac9e-64031481cf48"
    
    # Stub retrieve request
    stub_api_request(
      :get, 
      "/v1/customers/#{customer_id}", 
      "customer.json"
    )
    
    # Stub update request
    stub_api_request(
      :patch, 
      "/v1/customers/#{customer_id}", 
      "customer.json"
    )

    customer = Frame::Customer.retrieve(customer_id)
    customer.name = "John Updated"
    customer.save

    assert_requested :patch, "#{Frame.api_base}/v1/customers/#{customer_id}", times: 1
  end

  def test_delete_customer
    customer_id = "a8d21fd2-b5ae-499f-b844-c0a66fe183b5"
    
    # Stub delete request
    stub_api_request(
      :delete, 
      "/v1/customers/#{customer_id}", 
      "deleted_customer.json"
    )

    deleted_customer = Frame::Customer.delete(customer_id)
    
    assert_equal customer_id, deleted_customer.id
    assert_equal true, deleted_customer.deleted
    assert_equal "customer", deleted_customer.object

    # Verify the request was made
    assert_requested :delete, "#{Frame.api_base}/v1/customers/#{customer_id}", times: 1
  end

  def test_list_customers
    # Stub list request
    stub_api_request(
      :get, 
      "/v1/customers", 
      "customers_list.json"
    )

    customers = Frame::Customer.list
    assert_equal 2, customers.data.size
    assert_equal "55435398-ec47-4bb4-ac9e-64031481cf48", customers.data.first.id
    assert_equal "John", customers.data.first.name
    assert_equal "66543210-ab12-3cd4-ef56-789012345678", customers.data.last.id
    assert_equal "Jane", customers.data.last.name
    
    # Verify pagination methods
    assert_equal false, customers.has_more?
    assert_equal 1, customers.instance_variable_get(:@page)
  end

  def test_list_customers_with_params
    # Stub list request with params
    stub_api_request(
      :get, 
      "/v1/customers", 
      "customers_list.json",
      request_params: { page: 1, per_page: 20 }
    )

    customers = Frame::Customer.list(page: 1, per_page: 20)
    
    assert_equal 2, customers.data.size
    # Verify the request was made with correct parameters
    assert_requested :get, "#{Frame.api_base}/v1/customers", 
                    query: { page: 1, per_page: 20 },
                    times: 1
  end

  def test_search_customers
    # Stub search request with query parameters
    stub_api_request(
      :get, 
      "/v1/customers/search", 
      "search_customers.json",
      request_params: { name: "John" }
    )

    customers = Frame::Customer.search(name: "John")
    
    assert_equal 1, customers.data.size
    assert_equal "55435398-ec47-4bb4-ac9e-64031481cf48", customers.data.first.id
    assert_equal "John", customers.data.first.name
    
    # Verify the request was made with the query parameters
    assert_requested :get, "#{Frame.api_base}/v1/customers/search", 
                    query: { name: "John" },
                    times: 1
  end

  def test_block_customer
    customer_id = "55435398-ec47-4bb4-ac9e-64031481cf48"
    
    # Stub retrieve request
    stub_api_request(
      :get, 
      "/v1/customers/#{customer_id}", 
      "customer.json"
    )
    
    # Stub block request
    stub_api_request(
      :post, 
      "/v1/customers/#{customer_id}/block", 
      "blocked_customer.json"
    )

    customer = Frame::Customer.retrieve(customer_id)
    blocked_customer = customer.block
    
    assert_equal customer_id, blocked_customer.id
    assert_equal "blocked", blocked_customer.status
    
    # Verify the request was made
    assert_requested :post, "#{Frame.api_base}/v1/customers/#{customer_id}/block", times: 1
  end

  def test_unblock_customer
    customer_id = "55435398-ec47-4bb4-ac9e-64031481cf48"
    
    # Stub retrieve request
    stub_api_request(
      :get, 
      "/v1/customers/#{customer_id}", 
      "blocked_customer.json"
    )
    
    # Stub unblock request
    stub_api_request(
      :post, 
      "/v1/customers/#{customer_id}/unblock", 
      "unblocked_customer.json"
    )

    customer = Frame::Customer.retrieve(customer_id)
    unblocked_customer = customer.unblock
    
    assert_equal customer_id, unblocked_customer.id
    assert_equal "active", unblocked_customer.status
    
    # Verify the request was made
    assert_requested :post, "#{Frame.api_base}/v1/customers/#{customer_id}/unblock", times: 1
  end
end