# frozen_string_literal: true

module Frame
  class ListObject < FrameObject
    include Enumerable
    include Frame::APIOperations::Request

    attr_accessor :filters, :resource_url, :data

    def initialize(data = {}, opts = {})
      super(nil, opts)
      @data = data[:data] || []
      @filters = {}
      @resource_url = opts[:resource_url]
      @has_more = data[:meta] && data[:meta][:has_more]
      @page = data[:meta] && data[:meta][:page] || 1
    end

    def self.construct_from(values, opts = {})
      data = values || {}
      
      # Initialize from the values - excluding the :data key to avoid accessor conflicts
      # We'll handle data manually since it's declared as an attribute
      obj = new(data, opts)
      
      # Store original values except data
      values_without_data = values.dup
      data_array = values_without_data.delete(:data)
      
      # Initialize from values without data first
      obj.initialize_from(values_without_data, opts)
      
      # Then process the data array
      if data_array && data_array.is_a?(Array)
        converted_data = data_array.map { |item| Util.convert_to_frame_object(item, opts) }
        obj.instance_variable_set(:@data, converted_data)
      end

      obj
    end
    
    def self.empty_list(opts = {})
      construct_from({data: [], meta: {has_more: false, page: 1}}, opts)
    end

    def [](index)
      @data[index]
    end

    def each(&blk)
      @data.each(&blk)
    end

    def empty?
      @data.empty?
    end

    def first
      @data.first
    end

    def last
      @data.last
    end

    def retrieve(id, opts = {})
      resource_class = object_class_for_data
      return resource_class.retrieve(id, opts) if resource_class
      nil
    end

    def next_page(params = {}, opts = {})
      return self.class.empty_list(opts) unless has_more?

      params = filters.merge(params || {})
      params[:page] = @page + 1 if @page
      
      # Get the resource URL - try all possible fallbacks
      url = self.resource_url || 
            (self.class.respond_to?(:resource_url) ? self.class.resource_url : nil) ||
            "/v1/customers" # Default if we can't determine it
            
      response = request(:get, url, params, opts)
      Util.convert_to_frame_object(response, opts)
    end

    def has_more?
      !!@has_more
    end

    def total_count
      @data.size
    end

    def to_hash
      {
        data: @data.map { |i| i.is_a?(FrameObject) ? i.to_hash : i },
        meta: {
          has_more: has_more?,
          page: @page
        }
      }
    end

    private

    def object_class_for_data
      return nil if @data.empty?
      
      # Get first item's object type, whether it's already a FrameObject or still a Hash
      first_item = @data.first
      object_name = if first_item.is_a?(FrameObject)
                      first_item[:object]
                    elsif first_item.is_a?(Hash)
                      first_item[:object]
                    else
                      nil
                    end
      
      Util.object_classes_to_constants[object_name] if object_name
    end
  end
end