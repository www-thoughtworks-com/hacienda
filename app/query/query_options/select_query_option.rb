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
          result[query_field.to_sym] = content_item[query_field.to_sym]
        end
        items << result
      end
      items
    end
  end
end