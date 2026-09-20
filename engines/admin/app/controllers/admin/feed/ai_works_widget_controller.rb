module Admin
  module Feed
    class AiWorksWidgetController < AdminController
      SAMPLE_SIZE = 5

      def show
        fetch_view_data
      end

      private

      def fetch_view_data
        summaries_to_verify_scope = Admin::Tasks::AiBookFetch.where(status: :fetched)
        @summaries_to_verify = summaries_to_verify_scope.preload(target: :authors).first(SAMPLE_SIZE)
        @summaries_to_verify_count = summaries_to_verify_scope.count

        fetched_lists_to_verify_scope = Admin::Tasks::AiAuthorWorksFetch.where(status: :fetched)
        @fetched_lists_to_verify = fetched_lists_to_verify_scope.preload(:target).first(SAMPLE_SIZE)
        @fetched_lists_to_verify_count = fetched_lists_to_verify_scope.count

        parsed_lists_to_verify_scope = Admin::Tasks::AiAuthorWorksParse.where(status: :fetched)
        @parsed_lists_to_verify = parsed_lists_to_verify_scope.preload(:target).first(SAMPLE_SIZE)
        @parsed_lists_to_verify_count = parsed_lists_to_verify_scope.count
      end
    end
  end
end
