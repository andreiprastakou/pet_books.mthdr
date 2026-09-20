# frozen_string_literal: true

module Admin
  module ExternalLinkBuilders
    # Builds a user-facing URL for an external resource identifier.
    class Base
      def self.call(identificator)
        new(identificator).url
      end

      def initialize(identificator)
        @identificator = identificator
      end

      def url
        id = normalized_id
        return if id.blank?

        build_url(id)
      end

      private

      attr_reader :identificator

      def normalized_id
        identificator.to_s.strip.presence
      end

      def build_url(_id)
        raise NotImplementedError, "#{self.class} must implement #build_url"
      end

      def strip_url_noise(value)
        cleaned = value.to_s.strip
        return if cleaned.blank?

        cleaned = cleaned.delete_prefix('https://').delete_prefix('http://')
        cleaned.split('?', 2).first.to_s.split('#', 2).first.presence
      end

      class << self
        protected

        def strip_site_identificator(identificator, *hosts)
          value = identificator.to_s.strip
          return if value.blank?

          value = value.delete_prefix('https://').delete_prefix('http://')
          value = value.split('?', 2).first.to_s.split('#', 2).first.presence
          return if value.blank?

          hosts.each do |host|
            value = value.delete_prefix("www.#{host}").delete_prefix(host)
          end
          value
        end

        def normalize_path_id(identificator, host:, path_regex:, bare_regex:)
          value = strip_site_identificator(identificator, host)
          return if value.blank?

          if (match = value.match(path_regex))
            match[1]
          elsif value.match?(bare_regex)
            value
          end
        end
      end
    end
  end
end
