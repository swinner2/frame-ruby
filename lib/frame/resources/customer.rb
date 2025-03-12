# frozen_string_literal: true

module Frame
  class Customer < APIResource
    extend Frame::APIOperations::Create
    extend Frame::APIOperations::List
    include Frame::APIOperations::Delete
    include Frame::APIOperations::Save

    OBJECT_NAME = "customer".freeze

    def self.object_name
      OBJECT_NAME
    end

    def self.create(params = {}, opts = {})
      request_object(
        :post,
        "/v1/customers",
        params,
        opts
      )
    end

    def self.list(params = {}, opts = {})
      request_object(
        :get,
        "/v1/customers",
        params,
        opts
      )
    end

    def self.retrieve(id, opts = {})
      id = Util.normalize_id(id)
      request_object(
        :get,
        "/v1/customers/#{CGI.escape(id)}",
        {},
        opts
      )
    end

    def self.search(params = {}, opts = {})
      request_object(
        :get,
        "/v1/customers/search",
        params,
        opts
      )
    end

    def self.delete(id, params = {}, opts = {})
      request_object(
        :delete,
        "/v1/customers/#{CGI.escape(id)}",
        params,
        opts
      )
    end

    def block(params = {}, opts = {})
      request_object(
        :post,
        "/v1/customers/#{CGI.escape(self['id'])}/block",
        params,
        opts
      )
    end

    def self.block(id, params = {}, opts = {})
      request_object(
        :post,
        "/v1/customers/#{CGI.escape(id)}/block",
        params,
        opts
      )
    end

    def unblock(params = {}, opts = {})
      request_object(
        :post,
        "/v1/customers/#{CGI.escape(self['id'])}/unblock",
        params,
        opts
      )
    end

    def self.unblock(id, params = {}, opts = {})
      request_object(
        :post,
        "/v1/customers/#{CGI.escape(id)}/unblock",
        params,
        opts
      )
    end

    def save(params = {}, opts = {})
      values = serialize_params(self).merge(params)

      if values.empty?
        return self
      end

      updated = request_object(
        :patch,
        "/v1/customers/#{CGI.escape(self['id'])}",
        values,
        opts
      )

      initialize_from(updated)
      self
    end

    def delete(params = {}, opts = {})
      request_object(
        :delete,
        "/v1/customers/#{CGI.escape(self['id'])}",
        params,
        opts
      )
    end
  end
end