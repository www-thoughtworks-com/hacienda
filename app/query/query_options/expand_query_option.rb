# frozen_string_literal: true
require_relative '../query_runner'

module Hacienda
  # Class to select specific fields from result
  class ExpandQueryOption
    def initialize(query_option_value)
      @query_option_value = query_option_value
    end

    def apply(content)
      items = []
      content.each do |content_item|
        result_hash = {}
        field_names = @query_option_value.split(',')
        field_names.each do |field| 
          field_name_array = field.split('(')
          
          if field_name_array.length < 2
            raise "No selectors available for field #{field_name_array[0]}. Use empty parenthesis if no selectors intended."
          end
          
          field_name = field_name_array[0]
          field_value =  content_item[field_name.to_sym]
          
          query_string = field_name_array[1].chomp(')')
          
          unless query_string.empty?
            query = QueryRunner.new(parse_query(query_string))
            field_value = query.apply(field_value)
          end

          result_hash[field_name.to_sym] = field_value
        end
        items << result_hash
      end
      items
    end
    
    def parse_query(query_string)
      query_hash = {}
      query_string.split('&').each do |q|
        key_values = q.split('=')
        query_hash[key_values[0]] = key_values[1]
      end
      query_hash
    end
  end
end
