# frozen_string_literal: true

module Api
  module Books
    class FullEntriesController < Api::Books::BaseController
      PERMITTED_ATTRIBUTES = [
        :title,
        :year_published,
        :original_title,
        :goodreads_url,
        { tag_names: [] },
        { author_ids: [] }
      ].freeze

      before_action :fetch_book, only: %i[show update destroy]

      protect_from_forgery with: :null_session

      def show; end

      def create
        @book = Book.new
        perform_form_create(Forms::BookForm.new(@book), book_params, @book)
      end

      def update
        perform_form_update(Forms::BookForm.new(@book), book_params)
      end

      def destroy
        @book.destroy!
        render json: {}
      end

      private

      def book_params
        params.fetch(:book, {})
              .permit(*PERMITTED_ATTRIBUTES)
      end
    end
  end
end
