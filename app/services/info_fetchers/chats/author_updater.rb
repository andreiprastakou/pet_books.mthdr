module InfoFetchers
  module Chats
    class AuthorUpdater < InfoFetchers::BaseFetcher
      def apply_updates(author)
        ai_talker = InfoFetchers::Chats::AuthorsExpert.new
        info = ai_talker.ask_books_list(author.fullname)
        update_author(author, info.fetch('author'))
        update_books(author, info.fetch('books'))
        nil
      end

      private

      def update_author(author, author_info)
        country_tags = extract_tags(author_info, 'countries', :location)
        author.update!(
          original_fullname: author_info.fetch('original_name'),
          tags: author.tags | country_tags,
          birth_year: author_info.fetch('birth_year'),
          death_year: author_info.fetch('death_year')
        )
        Rails.logger.info "Author ID=#{author.id} updated"
      end

      def update_books(author, books_info)
        books_info.each do |book_info|
          book = Book.where(title: book_info.fetch('title')).by_author(author).first_or_initialize(authors: [author])
          book.update!(
            original_title: book_info.fetch('original_title'),
            year_published: book_info.fetch('publishing_year')
          )
          Rails.logger.info "Book ID=#{book.id} updated"
        end
      end
    end
  end
end
