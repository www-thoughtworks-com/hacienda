

module Cobra
  class NoIndexUrlsProvider

    def initialize(content_service_store)
      @content_service_store = content_service_store
    end

    def is_url_non_indexable?(id, locale) 
      no_index_urls_json = @content_service_store.find_by_id(:no_index, locale)
      no_index_urls_json[locale.to_sym].include?(id)
    end
  end
end

