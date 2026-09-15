module Admin
  module Authors
    class WikiStatsController < AdminController
      def update
        author = Admin::Author.find(params[:author_id])
        books = books_to_sync(author)
        if books.any?
          books.each do |book|
            InfoFetchers::Wiki::BookSyncer.new(book).sync!
          end
          redirect_to admin_author_path(author), notice: t('notices.admin.author_wiki_stats.update.success')
        else
          redirect_to admin_author_path(author), alert: t('notices.admin.author_wiki_stats.update.none')
        end
      end

      private

      def books_to_sync(author)
        Admin::Book.for_scope(author.books, :external_links, :wiki_links).select do |book|
          book.wiki_url.present? && book.wiki_popularity.zero?
        end
      end
    end
  end
end
