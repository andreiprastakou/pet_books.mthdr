# frozen_string_literal: true

module FrontendApi
  module Books
    class ReadsController < FrontendApi::Books::BaseController
      before_action :fetch_book

      def update
        @read = true
        mark_read
      end

      def destroy
        @read = false
        UserBookRead.where(user: current_user, book: @book).delete_all
        render :update
      end

      private

      def mark_read
        UserBookRead.find_or_create_by!(user: current_user, book: @book)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
