# frozen_string_literal: true

module Frame
  module APIOperations
    module Create
      def create(params = {}, opts = {})
        request_object(
          :post,
          resource_url,
          params,
          opts
        )
      end
    end
  end
end
