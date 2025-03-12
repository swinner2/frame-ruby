# frozen_string_literal: true

module Frame
  class APIResource < FrameObject
    include Frame::APIOperations::Request

    def self.class_name
      name.split('::')[-1]
    end

    def self.resource_url
      if self == APIResource
        raise NotImplementedError,
              "APIResource is an abstract class. You should perform actions " \
              "on its subclasses (Customer, etc.)"
      end

      "/v1/#{object_name.downcase}s"
    end

    def self.retrieve(id, opts = {})
      id = Util.normalize_id(id)
      instance = new(id, opts)
      instance.refresh(opts)
      instance
    end

    def resource_url
      unless (id = self['id'])
        raise InvalidRequestError.new(
          "Could not determine which URL to request: #{self.class} instance " \
          "has invalid ID: #{id.inspect}",
          'id'
        )
      end
      "#{self.class.resource_url}/#{CGI.escape(id)}"
    end

    def refresh(opts = {})
      response = request(:get, resource_url, {}, opts)
      initialize_from(response, opts)
      self
    end
  end
end