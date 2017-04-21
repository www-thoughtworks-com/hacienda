require 'json'
require_relative 'metadata'

module Hacienda

  class MetadataFactory

    def from(metadata_hash)
      Metadata.new(metadata_hash)
    end

    def from_string(metadata_string)
      from(JSON.parse(metadata_string, symbolize_names: true))
    end

    def create(id, locale, datetime, author, category: nil)
      Metadata.new(construct_metadata_hash(id, locale, datetime, author, category))
    end

    private

    def construct_metadata_hash(id, locale, datetime, author, category)
      metadata_hash = {
          id: id,
          canonical_language: locale,
          available_languages: {
              :draft => [locale],
              :public => []
          },
          last_modified: {
              locale.to_sym => datetime
          },
          last_modified_by: {
              locale.to_sym => author
          }
      }

      metadata_hash[:category] = category unless category.nil?
      metadata_hash
    end
  end

end
