require_relative '../../app/exceptions/resource_not_found_error'
require_relative '../../app/exceptions/http_error'
require_relative '../../spec/shared/responses/status_response'
require_relative '../../spec/functional/support/rack_client'
require_relative '../shared/content_item'
require_relative '../../app/security/cryptography'
require_relative '../../spec/utilities/fake_config_loader'
require_relative 'key_mocking'
require 'securerandom'
require 'json'

module Hacienda
  module Test

    TEST_REPO = '/tmp/functional_test_repo' 

    module Navigation

      def get_draft_translated_item_by_id(type, id, locale)
        get_json_from_path("/#{type}/#{id}", '', set_accept_language(locale))
      end

      def get_draft_items(type, locale)
        get_json_from_path("/#{type}", '', set_accept_language(locale))
      end

      def get_draft_item_version(type, id, locale, versions_in_the_past)
        get_json_from_path("/#{type}/#{id}/#{locale}","v=-#{versions_in_the_past}")
      end

      def get_public_translated_item_by_id(type, id, locale)
        get_json_from_path("/#{type}/#{id}/public", '', set_accept_language(locale))
      end

      def get_public_items(type, locale, query='')
        get_json_from_path("/#{type}/public", query, set_accept_language(locale))
      end

      def get_item_for_locale(item, locale)
        get_draft_translated_item_by_id(item.type, item.id, locale)
      end

      def upload_image(image_path, file_contents, authorisation_data)
        headers = authorisation_headers(file_contents, authorisation_data).merge('Content-Type' => 'image/png')
        client.put("file/#{image_path}", file_contents, headers)
      end

      def un_publish_item_with_locale(type,id, authorisation_data, locale)
        headers = authorisation_headers('', authorisation_data)
        client.delete("/#{type}/#{id}/#{locale}/public", headers)
      end

      def delete_item_with_locale(type, id, authorisation_data, locale)
        headers = authorisation_headers('', authorisation_data)
        client.delete("/#{type}/#{id}/#{locale}", headers)
      end

      def delete_item(type, id, authorisation_data)
        headers = authorisation_headers('', authorisation_data)
        client.delete("/#{type}/#{id}", headers)
      end

      def create_item(type, item_data, locale, authorisation_data)
        content_for_encryption = prepare_content(item_data)
        headers = authorisation_headers(content_for_encryption, authorisation_data).merge({'Username' => 'bob'})
	
        client.post("/#{type}/#{locale}",
                    {
                        data: item_data.to_json
                    },
                    headers)
      end

      def update_item(type, item_data, locale, authorisation_data)
        content = prepare_content(item_data)
        headers = authorisation_headers(content, authorisation_data).merge({'Username' => 'bob'})
        client.put("/#{type}/#{item_data[:id]}/#{locale}",
                   {
                       data: item_data.to_json
                   },
                   headers)
      end

      def publish_single_content_item(content_type, item_id, authorisation_data, version_to_publish, locale)
        headers = authorisation_headers('', authorisation_data)
        headers['If-Match'] = version_to_publish
        client.post("/#{content_type}/#{item_id}/#{locale}", '', headers)
      end

      def get_status_response
        StatusResponse.new(get_response_from_path('/status'))
      end

      def github_tells_service_that_content_updated
        client.post '/content-updated', data: '{}'
      end

      def get_public_translated_response_status_code_for(type, id, locale)
        get_response_status_from_path("/#{type}/#{id}/public", set_accept_language(locale))
      end

      def get_draft_translated_response_status_code_for(type, id, locale)
        get_response_status_from_path("/#{type}/#{id}", set_accept_language(locale))
      end

      private

      def with_query(path, query)
        path = "#{path}"
        path += "?#{URI::encode(query)}" unless query.empty?
        path
      end

      def get_json_from_path(path, query='', headers = {})
        response_string = get_response_from_path(with_query(path,query), headers)
        JSON.parse(response_string, {symbolize_names: true})
      end

      def get_response_status_from_path(path, headers = {})
        response = client.get(path, headers)
        response.status
      end

      def prepare_content(item_data)
        "data=#{CGI.escape(item_data.to_json)}"
      end

      def authorisation_headers(content, authorisation_data)
        return {} if authorisation_data.nil?
        {
            'authorization' => "HMAC #{create_authorisation_hash(content, authorisation_data)}",
            'nonce' => authorisation_data[:nonce],
            'timestamp' => authorisation_data[:timestamp],
            'clientid' => authorisation_data[:client_id]
        }
      end

      def create_authorisation_hash(data, authorisation_data)
        Hacienda::Security::Cryptography.new.generate_authorisation_data(data, authorisation_data[:secret], authorisation_data[:nonce], authorisation_data[:timestamp])[:hash]
      end

      def get_response_from_path(path, headers = {})
        response = client.get(path, headers)
        raise Errors::ResourceNotFoundError.new(path) if response.status == 404
        raise Errors::HTTPError.new "Error received with code #{response.status} when requesting path #{path}" if response.status > 206
        response.body
      end

      def set_accept_language(locale)
        {'Accept-language' => locale}
      end

    end

  end
end
