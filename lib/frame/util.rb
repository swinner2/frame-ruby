# frozen_string_literal: true

module Frame
  module Util
    OBJECT_CLASSES = {
      # Additional classes will be added as they're implemented
      "customer" => "Customer",
      "list" => "ListObject"
    }.freeze

    def self.object_classes
      OBJECT_CLASSES
    end

    def self.convert_to_frame_object(resp, opts = {})
      case resp
      when Array
        resp.map { |i| convert_to_frame_object(i, opts) }
      when Hash
        # Try converting to a specific object class if this is a response with an object key
        object_name = resp[:object]

        if object_name && object_classes[object_name]
          klass = object_classes_to_constants[object_name]
          klass.construct_from(resp, opts)
        elsif resp[:data]&.is_a?(Array)
          # This is a list object
          ListObject.construct_from(resp, opts)
        else
          FrameObject.construct_from(resp, opts)
        end
      else
        resp
      end
    end

    def self.symbolize_names(object)
      case object
      when Hash
        new_hash = {}
        object.each do |key, value|
          key = begin
            key.to_sym
          rescue
            key
          end || key
          new_hash[key] = symbolize_names(value)
        end
        new_hash
      when Array
        object.map { |value| symbolize_names(value) }
      else
        object
      end
    end

    def self.normalize_id(id)
      id&.to_s
    end

    def self.normalize_opts(opts)
      opts.clone
    end

    def self.object_classes_to_constants
      @object_classes_to_constants ||= begin
        constants = {}
        object_classes.each do |object_name, class_name|
          # Store with both string and symbol keys for flexibility
          constants[object_name] = Frame.const_get(class_name, false)
          constants[object_name.to_sym] = Frame.const_get(class_name, false)
        end
        constants
      end
    end
  end
end
