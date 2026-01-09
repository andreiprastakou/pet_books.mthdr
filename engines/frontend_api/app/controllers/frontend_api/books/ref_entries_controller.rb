# frozen_string_literal: true

module FrontendApi
  module Books
    class RefEntriesController < Api::Books::BaseController
      before_action :fetch_book, only: :show

      def index
        books = BooksFilter.filtered_scope(params)
        books = apply_sort(books)
        @count = books.count
        @books = paginate(books)
      end

      def show; end

      private

      def apply_sort(books_scope)
        case params[:sort_by]
        when 'name' then books_scope.order(:title)
        when 'year' then books_scope.order(year_published: :desc)
        when 'popularity' then books_scope.order(popularity: :desc)
        else books_scope
        end
      end

      def paginate(books_scope)
        books_scope.page(params.fetch(:page, 1)).per(params.fetch(:per_page, 1000))
      end
    end
  end
end
