# frozen_string_literal: true

module Frame
  class FrameObject
    include Enumerable

    attr_reader :id, :values, :original_values

    def initialize(id = nil, opts = {})
      @id = id
      @values = {}
      @original_values = {}
      @unsaved_values = Set.new
    end

    def self.construct_from(values, opts = {})
      obj = new(values[:id])
      obj.initialize_from(values, opts)
      obj
    end

    def initialize_from(values, opts = {})
      @original_values = values.dup
      @values = values.dup
      
      # Make sure all keys are symbols
      @values.keys.each do |k|
        @values[k.to_sym] = @values.delete(k) unless k.is_a?(Symbol)
      end
      
      # Add accessors for all keys
      remove_accessors(@values.keys)
      add_accessors(@values.keys)
      
      self
    end

    def update_attributes(values)
      values.each do |k, v|
        @values[k] = Util.convert_to_frame_object(v)
      end
    end

    def [](key)
      @values[key.to_sym]
    end

    def []=(key, value)
      send(:"#{key}=", value)
    end

    def keys
      @values.keys
    end

    def values
      @values.values
    end

    def to_s(*_args)
      JSON.pretty_generate(@values)
    end

    def inspect
      id_string = @id.nil? ? "" : " id=#{@id}"
      "#<#{self.class}:0x#{object_id.to_s(16)}#{id_string}> JSON: " + JSON.pretty_generate(@values)
    end

    def to_hash
      @values.each_with_object({}) do |(key, value), hash|
        hash[key] = case value
                    when FrameObject
                      value.to_hash
                    when Array
                      value.map { |v| v.respond_to?(:to_hash) ? v.to_hash : v }
                    else
                      value
                    end
      end
    end

    def each(&blk)
      @values.each(&blk)
    end

    def serialize_params(obj)
      params = {}

      obj.instance_variable_get("@values").each do |key, value|
        if value.is_a?(FrameObject)
          params[key] = value.serialize_params(value)
        elsif value.is_a?(Array)
          params[key] = value.map { |v| v.is_a?(FrameObject) ? v.serialize_params(v) : v }
        else
          params[key] = value
        end
      end

      params
    end

    protected

    def metaclass
      class << self; self; end
    end

    def remove_accessors(keys)
      # Skip keys that should be ignored when adding/removing accessors
      ignored_keys = [:id, :data]
      
      metaclass.instance_eval do
        keys.each do |k|
          # Skip certain keys that have special handling
          next if ignored_keys.include?(k.to_sym)
          
          # Remove reader method if it exists
          remove_method(k.to_sym) if method_defined?(k.to_sym)
          
          # Remove writer method if it exists
          remove_method("#{k}=".to_sym) if method_defined?("#{k}=".to_sym)
        end
      end
    end

    def add_accessors(keys)
      # Skip keys that should be ignored when adding/removing accessors
      ignored_keys = [:id, :data]
      
      metaclass.instance_eval do
        keys.each do |k|
          # Skip certain keys that have special handling
          next if ignored_keys.include?(k.to_sym)

          define_method(k) { @values[k] }
          define_method("#{k}=") do |v|
            @values[k] = v
          end
        end
      end
    end
  end
end