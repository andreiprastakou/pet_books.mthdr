module Admin
  class FeedController < AdminController
    def show
      fetch_todos
    end

    private

    def fetch_todos
      @generative_summaries = Admin::BookSummaryTask.where(status: :fetched).order(created_at: :asc).limit(10)
    end
  end
end
