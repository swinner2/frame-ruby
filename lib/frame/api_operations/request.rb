# frozen_string_literal: true

module Frame
  module APIOperations
    module Request
      module ClassMethods
        def request(method, path, params = {}, opts = {})
          Frame::FrameClient.active_client.request(method, path, params, opts)
        end

        def request_object(method, path, params = {}, opts = {})
          resp = request(method, path, params, opts)
          Util.convert_to_frame_object(resp, opts)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      protected

      def request(method, path, params = {}, opts = {})
        opts = Util.normalize_opts(opts)
        self.class.request(method, path, params, opts)
      end

      def request_object(method, path, params = {}, opts = {})
        opts = Util.normalize_opts(opts)
        self.class.request_object(method, path, params, opts)
      end
    end
  end
end