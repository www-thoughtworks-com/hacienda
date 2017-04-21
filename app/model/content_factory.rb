require_relative 'content'

module Hacienda
  class ContentFactory

    def instance(id, content_data, type:, locale:, category:)
      Content.build(id, content_data, type: type, locale: locale, category: category)
    end
  end
end
