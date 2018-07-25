require 'sinatra/base'
require 'json'
require_relative '../../app/stores/file_data_store'
require_relative '../web/request_error_handler'
require_relative '../exceptions/page_not_found_error'
require_relative '../web/wiring'
require_relative '../../app/github/github_file_system'
require_relative '../../app/security/hmac_authorisation'
require_relative '../../app/web/halt'
require_relative '../web/wiring'

module Hacienda

  class HaciendaService < Sinatra::Base
    include Wiring

    # These settings should be set to false in order to circumvent Sinatra's default error handling in development
    set :show_exceptions, false
    set :raise_errors, false

    set(:auth) do |authorised|
      condition do
        halt_if.unauthorised(request) if authorised
      end
    end

    def has_accept_language(value)
      (not request.env['HTTP_ACCEPT_LANGUAGE'].nil?) == value
    end

    set(:has_language) do |value|
      condition do
        has_accept_language(value)
      end
    end

    #Status

    get '/status' do
      '{"status":"OK"}'
    end

    existing_item_regex = %r{/(?<type>\w+)/(?<id>.+)/(?<locale>(en|es|pt|cn|de))$}
    existing_item_regex_public = %r{/(?<type>\w+)/(?<id>.+)/(?<locale>(en|es|pt|cn|de))/public$}
    safe_delete_regex = %r{/(?<type>\w+)/(?<id>.+)/(?<locale>(en|es|pt|cn|de))/safe_delete$}

    #Content Updated

    post '/content-updated' do
      local_content_repo.pull_latest_content
      'content updated'
    end

    #Updating Generic

    put existing_item_regex, auth: true do
      put_response = update_content_controller.update(params[:type], params[:id], params[:data], params[:locale], request.env['HTTP_LAST_MODIFIED_BY'])

      sinatra_response(put_response)
    end

    #Publishing Generic

    post existing_item_regex, auth: true do
      publish_response = publish_content_controller.publish(params[:type], params[:id], request.env['HTTP_IF_MATCH'], params[:locale])

      sinatra_response(publish_response)
    end

    #Create

    create_item_regexp = %r{/(?<type>\w+)/(?<locale>(en|es|pt|cn|de))$}

    post create_item_regexp, auth: true do
      create_response = create_content_controller.create(params[:type], params[:data], params[:locale], request.env['HTTP_LAST_MODIFIED_BY'], content_category: request.env['HTTP_CONTENT_CATEGORY'])

      sinatra_response(create_response)
    end

    #Finding all Generic

    get '/:type/public', has_language: true do
      public_content_store.find_all(params[:type], get_accept_language).to_json
    end

    get '/:type', has_language: true do
      draft_content_store.find_all(params[:type], get_accept_language).to_json
    end

    #Getting Generic

    get %r{/(?<type>\w+)/(?<id>.+)/public}, has_language: true do
      public_content_store.find_one(params[:type], params[:id], get_accept_language).to_json
    end

    get %r{/(?<type>\w+)/(?<id>.+)}, has_language: true do
      draft_content_store.find_one(params[:type], params[:id], get_accept_language).to_json
    end

    #Getting history of an item

    get existing_item_regex do
      changes_in_the_past = (-1)*request.env['rack.request.query_hash']['v'].to_i
      draft_content_store.find_locale_resource(params[:type], params[:id], params[:locale], changes_in_the_past)
    end

    #Un-publish

    delete existing_item_regex_public, auth: true do
      un_publish_response = delete_content_controller.unpublish(params[:id], params[:type], params[:locale])
      sinatra_response(un_publish_response)
    end

    #Delete

    delete existing_item_regex, auth: true do
      delete_response = delete_content_controller.delete(params[:id], params[:type], params[:locale])
      sinatra_response(delete_response)
    end

    delete safe_delete_regex, auth: true do
      safe_delete_response = delete_content_controller.safe_delete(params[:id], params[:type], params[:locale])
      sinatra_response(safe_delete_response)
    end

    delete %r{/(?<type>\w+)/(?<id>.+)}, auth: true do
      delete_response = delete_content_controller.delete_all(params[:type], params[:id])

      sinatra_response(delete_response)
    end

    #Errors

    error do
      error_handler.handle(raised_error)
    end

    error 404 do
      error_handler.handle(Errors::PageNotFoundError.new('/'))
    end

    def raised_error
      request.env['sinatra.error']
    end

    def get_accept_language
      accepted_values = %w(en es pt de cn)
      passed_locale = request.env['HTTP_ACCEPT_LANGUAGE']
      accepted_values.include?(passed_locale) ? passed_locale : 'en'
    end

    def sinatra_response(service_http_response)
      service_http_response.apply_to_sinatra_response(self.response)
      service_http_response.body
    end


  end

end
