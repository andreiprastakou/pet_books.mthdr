# frozen_string_literal: true

module Admin
  module Books
    class WikipediaFetchesController < AdminController
      before_action :fetch_book

      def create
        task = Admin::Tasks::WikipediaBookFetch.setup(@book)
        task.enqueue_for_processing!
        redirect_to admin_book_path(@book), notice: t('notices.admin.wikipedia_fetches.create.success')
      end

      private

      def fetch_book
        @book = Book.find(params[:book_id])
      end
    end
  end
end
