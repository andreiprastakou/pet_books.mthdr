module Admin
  module Books
    class WikiStatsController < Admin::AdminController
      def update
        book = Book.find(params[:book_id])
        initial_popularity = book.wiki_popularity
        InfoFetchers::Wiki::BookSyncer.new(book).sync!
        if book.wiki_popularity > initial_popularity
          redirect_to admin_book_path(book), notice: t('notices.admin.book_wiki_stats.update.success')
        else
          redirect_to admin_book_path(book), alert: t('notices.admin.book_wiki_stats.update.none')
        end
      end
    end
  end
end
