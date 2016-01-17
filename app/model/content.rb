require_relative 'referenced_file'
require_relative '../exceptions/unprocessable_entity_error'
require_relative '../services/file_path_provider'

module Hacienda
  class Content

    MAX_ID_LENGTH = 150

    attr_reader :data, :referenced_files, :id

    def self.build(id, data, type:, locale:)
      referenced_files = get_html_fields_from_content_data(id, data)

      referenced_files.each do |referenced_file|
        replace_html_content_with_reference_to_html_file(data, referenced_file)
      end

      Content.new(id, data, referenced_files: referenced_files, type: type, locale: locale)
    end

    def initialize(id, data, referenced_files:, type:, locale:)
      @id = id
      @data = data
      @referenced_files = referenced_files
      @locale = locale
      @type = type
      @file_path_provider = FilePathProvider.new

      remove_unneeded_fields
      validate
    end

    def json_file_path
      @file_path_provider.draft_json_path_for(@id, @type, @locale)
    end

    def metadata_file_path
      @file_path_provider.metadata_path_for(@id, @type)
    end

    def referenced_file_path(referenced_file)
      @file_path_provider.draft_path_for(referenced_file.file_name, @type, @locale)
    end

    private

    def validate
      raise Errors::UnprocessableEntityError.new('An ID must be specified.') if (@id.nil? || @id.empty?)
      raise Errors::UnprocessableEntityError.new('The ID must not exceed 150 characters in length.') if (@id.length > MAX_ID_LENGTH)
    end

    def remove_unneeded_fields
      @data.delete :translated_locale
    end

    def self.replace_html_content_with_reference_to_html_file(data_hash, item)
      data_hash[item.ref_name] = item.file_name
      data_hash.delete(item.key)
      data_hash
    end

    def self.get_html_fields_from_content_data(id, data_hash)
      data_hash.select { |key| key.end_with?('_html') }.collect do |key, value|
        ReferencedFile.new(id, 'html', key, value)
      end
    end

  end

end
