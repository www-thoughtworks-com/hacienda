require_relative 'content'

module Hacienda
  class ContentFactory

    def instance(id, content_data, type:, locale:, content_category: nil)
      Content.build(id, content_data, type: type, locale: locale, content_category: content_category)
    end
  end
end
