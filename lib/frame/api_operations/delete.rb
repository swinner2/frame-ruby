# frozen_string_literal: true

module Frame
  module APIOperations
    module Delete
      def delete(params = {}, opts = {})
        request_object(
          :delete,
          resource_url,
          params,
          opts
        )
      end
    end
  end
end