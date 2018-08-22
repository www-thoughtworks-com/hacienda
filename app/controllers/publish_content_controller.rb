require_relative '../exceptions/not_found_exception'
require_relative '../exceptions/precondition_failed_error'
require_relative '../utilities/log'
require_relative '../services/file_path_provider'
require_relative '../metadata/metadata_factory'
require_relative '../web/service_http_response'

module Hacienda

  class PublishContentController

    GENERIC_CONTENT_PUBLISHED_COMMIT_MESSAGE = 'Content item published'

    def initialize(file_system, content_digest, log)
      @file_system = file_system
      @content_digest = content_digest
      @log = log
      @file_path_provider = FilePathProvider.new
      @metadata_factory = MetadataFactory.new
    end

    def publish(type, id, version_to_publish, locale)
      Log.context action: 'publishing', id: id do

        json_git_file = load_json_file(id, type, locale)
        html_files = load_dependency_files(json_git_file, type, locale)
        current_version = current_version(html_files, json_git_file)

        if version_to_publish != current_version
          @log.warn("Version mismatch when trying to publish #{type}/#{id} version from request (#{version_to_publish}), from github (#{current_version}), json: #{json_git_file.content}")
          raise Errors::PreconditionFailedError
        end

        public_json_path = @file_path_provider.public_json_path_for(id, type, locale)

        write_html_files(html_files, locale, type)

        metadata_path = @file_path_provider.metadata_path_for(id, type)
        metadata = @metadata_factory.from(get_metadata(metadata_path))
        metadata.add_public_language(locale) unless metadata.has_public_language?(locale)
        metadata.add_first_published(locale, DateTime.now)

        files = {
          public_json_path => json_git_file.content,
          metadata_path => metadata.to_json
        }

        @file_system.write_files(GENERIC_CONTENT_PUBLISHED_COMMIT_MESSAGE, files)

        response = ServiceHttpResponseFactory.ok_response({
            versions: {
                draft: current_version,
                public: current_version
            }
        }.to_json)
        response.content_type = 'application/json'
        response
      end
    end


    private

    def write_html_files(html_files, locale, type)
      html_files.each_pair do |filename, file|
        target_file_path1 = @file_path_provider.public_path_for(filename, type, locale)
        @file_system.write_files(GENERIC_CONTENT_PUBLISHED_COMMIT_MESSAGE, target_file_path1 => file.content)[target_file_path1]
      end
    end

    def get_metadata(metadata_path)
      JSON.parse(@file_system.get_content(metadata_path).content, symbolize_names: true)
    end


    def current_version(html_files, json_git_file)
      shas = []
      shas << json_git_file.sha
      html_files.each_value do |file|
        shas << file.sha
      end

      @content_digest.generate_digest(shas)
    end

    def load_dependency_files(git_file, type, locale)
      content = JSON.parse(git_file.content)
      html_file_names = content.select { |key| key.end_with? '_ref' }.values

      html_files = {}
      html_file_names.each do |filename|
        html_files[filename] = @file_system.get_content(@file_path_provider.draft_path_for(filename, type, locale))
      end
      html_files
    end

    def load_json_file(id, type, locale)
      @file_system.get_content(@file_path_provider.draft_json_path_for(id, type, locale))
    end


  end
end
