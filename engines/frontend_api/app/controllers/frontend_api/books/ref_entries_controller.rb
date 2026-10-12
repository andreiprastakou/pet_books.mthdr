# frozen_string_literal: true

module FrontendApi
  module Books
    class RefEntriesController < FrontendApi::Books::BaseController
      before_action :fetch_book, only: :show

      def index
        books = BooksFilter.filtered_scope(params, books_scope)
        books = apply_sort(books)
        @count = books.count
        @books = paginate(books)
      end

      def show; end

      private

      def books_scope
        scope = Book.preload(:authors)
        return shared_reads_scope(scope) if params[:reads_code].present?
        return scope.read_by(current_user) if ActiveModel::Type::Boolean.new.cast(params[:read])

        scope
      end

      def shared_reads_scope(scope)
        user = shared_reads_user
        user ? scope.read_by(user) : scope.none
      end

      def shared_reads_user
        return @shared_reads_user if defined?(@shared_reads_user)

        @shared_reads_user = UserReadsSharing.find_by(code: params[:reads_code].to_s.downcase)&.user
      end

      def apply_sort(books_scope)
        case params[:sort_by]
        when 'name' then books_scope.order(:title)
        when 'year' then books_scope.order(year_published: :desc)
        when 'popularity' then books_scope.order(popularity: :desc)
        when 'random' then books_scope.order(Arel.sql('RANDOM()'))
        when 'latest' then order_by_latest_read(books_scope)
        else books_scope
        end
      end

      def order_by_latest_read(books_scope)
        user = reads_owner
        return books_scope unless user

        books_scope.joins(:user_book_reads)
                   .where(user_book_reads: { user_id: user.id })
                   .order(user_book_reads: { created_at: :desc })
      end

      def reads_owner
        return shared_reads_user if params[:reads_code].present?
        return current_user if ActiveModel::Type::Boolean.new.cast(params[:read])

        nil
      end

      def paginate(books_scope)
        books_scope.page(params.fetch(:page, 1)).per(params.fetch(:per_page, 1000))
      end
    end
  end
end
