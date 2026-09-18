# frozen_string_literal: true

module Admin
  # Shared perform / normalize for Wikipedia page-intro fetch tasks.
  module WikipediaIntroFetchable
    extend ActiveSupport::Concern

    def perform
      title, language = wikipedia_title_and_language
      return save_missing_wikipedia_url_result if title.blank? || language.blank?

      save_wikipedia_intro_result(title, language)
    end

    def fetched_data_normalized
      description = extracted_description
      description.present? ? { 'description' => description } : {}
    end

    private

    def save_missing_wikipedia_url_result
      save_results!(nil, errors: [StandardError.new(missing_wikipedia_url_message)])
    end

    def save_wikipedia_intro_result(title, language)
      result = Admin::InfoFetchers::Wikipedia::Api::Fetcher.new(language: language).fetch_intro(title)
      if result
        save_results!(result)
      else
        save_results!(nil, errors: [StandardError.new(fetch_failure_message)])
      end
    end

    def wikipedia_owner
      raise NotImplementedError
    end

    def wikipedia_title_and_language
      url = wikipedia_owner.wiki_url
      return [nil, nil] if url.blank?

      Admin::InfoFetchers::Wiki::UrlParser.extract_base_name_and_locale(url)
    end

    def extracted_description
      data = fetched_data
      return unless data.is_a?(Hash)

      pages = data.dig('query', 'pages')
      return unless pages.is_a?(Array)

      page = pages.first
      return unless page.is_a?(Hash)
      return if page['missing']

      page['extract'].presence
    end

    def missing_wikipedia_url_message
      'Wikipedia URL is missing or invalid'
    end

    def fetch_failure_message
      'Failed to fetch Wikipedia page intro'
    end
  end
end
