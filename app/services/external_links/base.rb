# frozen_string_literal: true

module ExternalLinks
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
  end
end
