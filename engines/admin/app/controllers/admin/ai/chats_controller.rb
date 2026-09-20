module Admin
  module Ai
    class ChatsController < AdminController
      before_action :fetch_record, only: :show

      SORTING_MAP = %i[
        id
        ruby_llm_model_id
        created_at
        updated_at
      ].index_by(&:to_s).freeze

      def index
        @pagy, @chats = pagy(
          apply_sort(
            Ai::Chat.preload(:messages, :ruby_llm_usages, :model),
            SORTING_MAP,
            defaults: { sort_by: 'id', sort_order: 'desc' }
          )
        )
      end

      def show
        @messages = @chat.messages.preload(
          :ruby_llm_usages,
          :ruby_llm_tool_calls,
          :ruby_llm_parent_tool_call
        ).order(created_at: :asc)
      end

      private

      def fetch_record
        @chat = Ai::Chat.find(params[:id])
      end
    end
  end
end
