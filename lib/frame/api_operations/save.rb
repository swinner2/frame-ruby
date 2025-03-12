# frozen_string_literal: true

module Frame
  module APIOperations
    module Save
      def save(params = {}, opts = {})
        values = serialize_params(self).merge(params)

        if values.empty?
          return self
        end

        updated = request_object(
          :patch,
          resource_url,
          values,
          opts
        )

        initialize_from(updated)
        self
      end

      def serialize_params(obj)
        params = {}

        update_attributes = @values.keys.select do |k|
          @original_values.key?(k) && @values[k] != @original_values[k]
        end

        update_attributes.each do |attr|
          params[attr] = obj[attr]
        end

        params
      end
    end
  end
end