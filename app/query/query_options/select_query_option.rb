# frozen_string_literal: true

module Hacienda
  # Class to select specific fields from result
  class SelectQueryOption
    def initialize(query_option_value)
      @query_option_value = query_option_value
    end

    def apply(content)
      @query_option_value.split(',').length > 1 ? apply_multiple_select(content) : apply_single_select(content)
    end

    private

    def apply_single_select(content)
      items = []
      content.each do |content_item|
        items << content_item[@query_option_value.to_sym]
      end
      items
    end

    def apply_multiple_select(content)
      items = []
      content.each do |content_item|
        result = {}
        @query_option_value.split(',').each do |query_field|
          result[query_field.to_sym] = content_item[query_field.to_sym]
        end
        items << result
      end
      items
    end
  end
end