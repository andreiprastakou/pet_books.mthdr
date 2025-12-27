module InfoFetchers
  module Chats
    class BaseChat
      attr_reader :errors

      def initialize
        @errors = []
      end

      def chat
        raise NotImplementedError
      end
    end
  end
end
