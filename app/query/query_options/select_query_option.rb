# frozen_string_literal: true

module Hacienda
  # Class to select specific fields from result
  class SelectQueryOption
    ID_SELECTOR = "id"
    def initialize(query_option_value)
      @query_option_value = query_option_value
    end

    def apply(content)
      items = []
      content.each do |content_item|
        result = {}
        query_option_values = @query_option_value.split(',')
        query_option_values.push(ID_SELECTOR) unless query_option_values.include?(ID_SELECTOR)
        query_option_values.each do |query_field|
          query_field_levels = query_field.split('/')
          field_value = content_item
          query_field_levels.each do |field_level|
            field_value =  field_value.key?(field_level.to_sym) ? field_value[field_level.to_sym] : nil
            break if field_value == nil
          end
          result[query_field_levels.last.to_sym] = field_value
        end
        items << result
      end
      items
    end
  end
end