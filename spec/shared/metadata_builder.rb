module Hacienda
  module Test

    class MetadataBuilder

      def initialize
        @id = 'some-id'
        @canonical_language = ''
        @draft_languages = []
        @public_languages = []
        @last_modified = {}
        @first_published = {}
        @last_modified_by = {}
        @content_category = ''
        @page_owner= ''
      end

      def default
        @canonical_language = 'en'
        @draft_languages = ['en']
        @public_languages = ['en']
        self
      end

      def with_id(id)
        @id = id
        self
      end

      def with_draft_only_locale(locale)
        with_canonical(locale)
        @draft_languages = [ locale ]
        with_no_public_languages
        self
      end

      def with_published_locale(locale)
        with_canonical(locale)
        @draft_languages = [ locale ]
        with_public_languages locale
        self
      end

      def with_canonical(language)
        @canonical_language = language
        self
      end

      def with_draft_languages(*languages)
        @draft_languages += languages
        self
      end

      def with_no_draft_languages
        @draft_languages = []
        self
      end

      def with_public_languages(*languages)
        @public_languages += languages
        self
      end

      def with_no_public_languages
        @public_languages = []
        self
      end

      def with_last_modified(locale, datetime)
        @last_modified[locale.to_sym] = datetime
        self
      end

      def with_first_published(locale, datetime)
        @first_published[locale.to_sym] = datetime
        self
      end

      def without_last_modified
        @last_modified = nil
        self
      end

      def with_last_modified_by(locale, author)
        @last_modified_by[locale.to_sym] = author
        self
      end

      def without_last_modified_by
        @last_modified_by = nil
        self
      end

      def with_content_category(content_category)
        @content_category = content_category
        self
      end

      def with_page_owner(page_owner)
        @page_owner = page_owner
        self
      end

      def build
        hash = {
            id: @id,
            canonical_language: @canonical_language,
            available_languages: {
                draft: @draft_languages,
                public: @public_languages
            },
            content_category: @content_category
        }

        hash[:last_modified] = @last_modified if @last_modified
        hash[:first_published] = @first_published if @first_published
        hash[:last_modified_by] = @last_modified_by
        hash[:page_owner] =@page_owner
        hash
      end

      def build_object
        Hacienda::Metadata.new build
      end

    end

  end
end

