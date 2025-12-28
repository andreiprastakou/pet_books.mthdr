module Admin
  module LinksHelper
    def external_link_to(text, url, **options)
      link_to text, url, options.reverse_merge(target: '_blank')
    end

    def display_link_to(text, url, **options)
      link_to text, url, options.reverse_merge(target: '_blank', class: 'btn btn-link display-link')
    end

    def admin_link_to(text, url, **)
      link_to(text, url, **)
    end

    def admin_buttonly_link_to(text, url, **options)
      admin_link_to text, url, **options.reverse_merge(class: 'btn btn-link')
    end

    def admin_nav_crumbs(*crumbs)
      admin_nav_crumbs_for_header(crumbs)
      admin_nav_crumbs_for_page_title(crumbs)
    end

    def admin_nav_authors_link
      ['Authors', admin_authors_path]
    end

    def admin_nav_author_link(author)
      [truncate_crumb(author.fullname, length: 30), admin_author_path(author)]
    end

    def admin_nav_books_link
      ['Books', admin_books_path]
    end

    def admin_nav_book_link(book)
      ["\"#{truncate_crumb(book.title, length: 40)}\"", admin_book_path(book)]
    end

    def admin_nav_ai_chats_link
      ['AI Chats', admin_ai_chats_path]
    end

    def admin_nav_ai_chat_link(chat)
      ["Chat ##{chat.id}", admin_ai_chat_path(chat)]
    end

    def admin_nav_tags_link
      ['Tags', admin_tags_path]
    end

    def admin_nav_tag_link(tag)
      [truncate_crumb(tag.name), admin_tag_path(tag)]
    end

    def truncate_crumb(crumb, length: 20)
      truncate(crumb, length: length, separator: ' ', escape: false)
    end

    def author_display_path(author)
      "/authors/#{author.id}"
    end

    def book_display_path(book)
      "/books/#{book.id}"
    end

    def tag_display_path(tag)
      "/tags/#{tag.id}"
    end

    def admin_nav_cover_designs_link
      ['Cover Designs', admin_covers_cover_designs_path]
    end

    def admin_nav_cover_design_link(design)
      "\"#{truncate_crumb(design.name)}\""
    end

    def admin_nav_genres_link
      ['Genres', admin_genres_path]
    end

    def admin_nav_genre_link(genre)
      "\"#{truncate_crumb(genre.name)}\""
    end

    def admin_nav_data_fetch_tasks_link
      ['Data Fetch Tasks', admin_data_fetch_tasks_path]
    end

    def admin_nav_data_fetch_task_link(task)
      task.type
    end

    def admin_link_to_data_fetch_task_target(task)
      case task
      when Admin::BookSummaryTask
        admin_link_to "Book \"#{task.book.title}\" by #{task.book.author_names_label}", admin_book_path(task.book)
      else
        "Entity #{task.target_type} with ID=#{task.target_id}"
      end
    end

    private

    def admin_nav_crumbs_for_header(crumbs)
      crumbs_for_header = crumbs.map do |crumb|
        if crumb.is_a?(Array)
          link_to(*crumb)
        else
          crumb
        end
      end
      content_for :title, safe_join(crumbs_for_header, ' > ')
    end

    def admin_nav_crumbs_for_page_title(crumbs)
      crumbs_for_page_title = crumbs.map do |crumb|
        if crumb.is_a?(Array)
          crumb.first
        else
          crumb
        end
      end
      content_for :page_title, safe_join(crumbs_for_page_title, ' > ')
    end
  end
end
