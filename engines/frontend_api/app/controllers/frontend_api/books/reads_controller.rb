# frozen_string_literal: true

module FrontendApi
  module Books
    class ReadsController < FrontendApi::Books::BaseController
      before_action :fetch_book

      def update
        @read = true
        @included_work_ids = UserBookRead.mark!(current_user, @book)
      end

      def destroy
        @read = false
        UserBookRead.where(user: current_user, book: @book).delete_all
        render :update
      end
    end
  end
end
