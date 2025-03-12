# frozen_string_literal: true

module Frame
  module APIOperations
    module List
      def list(params = {}, opts = {})
        request_object(
          :get,
          resource_url,
          params,
          opts
        )
      end
    end
  end
end