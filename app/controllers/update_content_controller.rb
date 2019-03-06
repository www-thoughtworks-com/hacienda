require_relative '../github/github_file_system'
require_relative '../utilities/log'
require_relative '../model/content'
require_relative '../stores/content_store'
require_relative '../web/service_http_response'
require_relative '../model/content_factory'

require 'json'

module Hacienda
  class UpdateContentController

    GENERIC_CONTENT_CHANGED_COMMIT_MESSAGE = 'Content item modified'

    def initialize(github, content_digest, content_store, log, content_factory: ContentFactory.new)
      @github = github
      @content_digest = content_digest
      @content_store = content_store
      @log = log
      @content_factory = content_factory
    end

    def update(type, id, content_json, locale, author, page_owner)
      content_data = JSON.parse(content_json)
      content = @content_factory.instance(id, content_data, type: type, locale: locale)

      Log.context action: 'updating content item', type: type, id: content.id do
        if content.exists_in? @github
          response = update_content(author, content, id, locale, type, page_owner)
        else
          response = ServiceHttpResponseFactory.not_found_response
        end
        response
      end
    end

    private

    def update_content(author, content, id, locale, type, page_owner)

      updated_version = content.write_to @github, author, GENERIC_CONTENT_CHANGED_COMMIT_MESSAGE, @content_digest, page_owner

      response = ServiceHttpResponseFactory.ok_response({
                                                          versions: {
                                                            draft: updated_version,
                                                            public: get_public_version(id, locale, type)
                                                          }
                                                        }.to_json)

      response.etag = updated_version
      response.content_type = 'application/json'
      response
    end

    def get_public_version(id, locale, type)
      begin
        @content_store.find_one(type, id, locale)[:versions][:public]
      rescue Errors::FileNotFoundError
        @log.info("Trying to get the public version of type #{type} for id #{id} but did not find any")
        nil
      end
    end
  end
end
