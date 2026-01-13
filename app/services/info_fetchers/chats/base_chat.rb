module InfoFetchers
  module Chats
    class BaseChat
      class << self
        def has_instructions(file_name, overrides = {})
          @instructions_file_name = file_name
          @instructions_overrides = overrides
        end

        def instructions(overrides = {})
          @instructions ||= build_instructions
          apply_instructions_overrides(
            @instructions, overrides
          )
        end

        private

        def build_instructions
          apply_instructions_overrides(
            fetch_instructions_template,
            @instructions_overrides
          )
        end

        def apply_instructions_overrides(content, overrides)
          overrides.each do |placeholder, value|
            content = content.gsub(placeholder, value.to_s)
          end
          content
        end

        def fetch_instructions_template
          raise "Instructions file not set" if @instructions_file_name.blank?

          path = Rails.root.join('config', 'prompts', @instructions_file_name)
          unless File.exist?(path)
            raise ArgumentError, "Instructions file not found: #{path}"
          end

          File.read(path)
        end
      end

      attr_reader :errors

      delegate :instructions, to: :class

      def initialize
        @errors = []
      end

      def chat
        raise NotImplementedError
      end
    end
  end
end
