# frozen_string_literal: true

module Frame
  class ListObject < FrameObject
    include Enumerable
    include Frame::APIOperations::Request

    attr_accessor :filters
    attr_reader :resource_url, :data

    def initialize(data = {}, opts = {})
      super(nil, opts)
      @data = data[:data] || []
      @filters = {}
      @resource_url = opts[:resource_url]
      @has_more = data[:meta] && data[:meta][:has_more]
      @page = data[:meta] && data[:meta][:page] || 1

      # Extract per_page from URL if available
      @per_page = if data.dig(:meta, :url)&.include?("per_page=")
        begin
          data[:meta][:url].match(/per_page=(\d+)/)[1].to_i
        rescue
          10
        end
      else
        10
      end
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
      if data_array&.is_a?(Array)
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
      next_page_num = @page + 1 if @page
      params[:page] = next_page_num
      params[:per_page] = @per_page if @per_page

      # Get the resource URL - try all possible fallbacks
      url = resource_url ||
        (self.class.respond_to?(:resource_url) ? self.class.resource_url : nil) ||
        "/v1/customers" # Default if we can't determine it

      response = request(:get, url, params, opts)
      result = Util.convert_to_frame_object(response, opts)

      # Update this object's state with the next page's data
      if result && !result.empty?
        @page = next_page_num
        @data = result.data
        @has_more = result.has_more?

        self
      else
        result
      end
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
          page: @page,
          per_page: @per_page
        }
      }
    end

    def inspect
      meta_info = "#<#{self.class.name}:0x#{object_id.to_s(16)} @page=#{@page} @per_page=#{@per_page} @has_more=#{@has_more} items=#{@data.size}>"

      # If data is empty, just return meta info
      return meta_info if @data.empty?

      # Format each item in the data array
      data_strings = @data.map do |item|
        if item.is_a?(FrameObject) && item.respond_to?(:id) && item.id
          obj_name = item.class.name.split("::").last
          "  #<#{obj_name}:#{item.id} #{item.inspect}>"
        else
          "  #{item.inspect}"
        end
      end

      "#{meta_info}\ndata=[\n#{data_strings.join(",\n")}\n]"
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
      end

      Util.object_classes_to_constants[object_name] if object_name
    end
  end
end
