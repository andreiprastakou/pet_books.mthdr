module InfoFetchers
  module Chats
    class BaseChat
      attr_reader :errors

      def chat
        raise NotImplementedError
      end
    end
  end
end
