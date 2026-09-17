module Admin
  module LinksHelper
    def external_link_to(text, url, **options)
      link_to text, url, options.reverse_merge(target: '_blank')
    end

    # Colored chain icon (emoji glyphs ignore CSS `color`).
    def external_link_icon_to(url, **options)
      external_link_to(
        external_link_chain_icon,
        url,
        **options.reverse_merge(class: 'b-external-link-icon-link', title: url.to_s)
      )
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
      task.model_name.human
    end

    def admin_link_to_data_fetch_task_target(task)
      case task
      when Admin::Tasks::AiBookFetch, Admin::Tasks::LibraryThingBookSearch, Admin::Tasks::OpenLibraryBookSearch,
           Admin::Tasks::WikidataBookSearch, Admin::Tasks::WikipediaBookFetch
           admin_link_to_data_fetch_task_book(task.book)
      when Admin::Tasks::AiAuthorWorksParse, Admin::Tasks::AiAuthorWorksFetch, Admin::Tasks::OpenLibraryAuthorSearch,
            Admin::Tasks::WikidataAuthorSearch, Admin::Tasks::WikipediaAuthorFetch
        admin_link_to_data_fetch_task_author(task.author)
      when Admin::Tasks::OpenLibraryBookFetch, Admin::Tasks::OpenLibraryAuthorFetch,
           Admin::Tasks::WikidataBookFetch, Admin::Tasks::WikidataAuthorFetch
        identity = task.external_identity
        owner = identity.owner
        if owner.is_a?(::Book)
          admin_link_to_data_fetch_task_book(owner)
        elsif owner.is_a?(::Author)
          admin_link_to_data_fetch_task_author(owner)
        else
          "#{identity.external_resource} #{identity.external_id}"
        end
      else
        "Entity #{task.target_type} with ID=#{task.target_id}"
      end
    end

    def admin_link_to_data_fetch_task_book(book)
      admin_link_to "Book \"#{book.title}\" (#{book.year_published}) by #{book.author_names_label}", admin_book_path(book)
    end

    def admin_link_to_data_fetch_task_author(author)
      admin_link_to "Author #{author.fullname}", admin_author_path(author)
    end

    def admin_nav_series_index_link
      ['Series', admin_series_index_path]
    end

    def admin_nav_series_link(series)
      "\"#{truncate_crumb(series.name)}\""
    end

    def admin_nav_collections_link
      ['Collections', admin_collections_path]
    end

    def admin_nav_collection_link(collection)
      "\"#{truncate_crumb(collection.name)}\""
    end

    def admin_nav_public_list_types_link
      ['Public List Types', admin_public_list_types_path]
    end

    def admin_nav_public_list_type_link(public_list_type)
      ["\"#{truncate_crumb(public_list_type.name)}\"", admin_public_list_type_path(public_list_type)]
    end

    def admin_nav_public_lists_link
      ['Public Lists', admin_public_lists_path]
    end

    def admin_nav_public_list_link(public_list)
      public_list.year
    end

    def admin_external_link_to(entity, external_link)
      label = external_link_to(external_link.external_resource, external_link.url)
      return label unless wikipedia_external_link?(external_link)

      content_tag(:span, class: 'text-muted') do
        safe_join([
                    label,
                    ' ('.html_safe,
                    safe_join(wikipedia_link_details(entity), ', '),
                    ')'.html_safe
                  ])
      end
    end

    def admin_external_links_list(entity)
      return if entity.external_links.blank?

      safe_join(
        entity.external_links.map { |external_link| admin_external_link_to(entity, external_link) },
        ' '
      )
    end

    private

    def wikipedia_link_details(entity)
      details = [
        pluralize(entity.wiki_links.count, 'page'),
        pluralize(entity.wiki_links_sum_views, 'view')
      ]
      fetch_link = wikipedia_intro_fetch_link(entity)
      details << fetch_link if fetch_link
      details
    end

    def wikipedia_intro_fetch_link(entity)
      path = wikipedia_intro_fetch_path(entity)
      return if path.blank?

      admin_link_to('fetch', path, data: { turbo_method: :post })
    end

    def wikipedia_intro_fetch_path(entity)
      case entity
      when ::Book
        admin_book_wikipedia_fetches_path(entity)
      when ::Author
        admin_author_wikipedia_fetches_path(entity)
      end
    end

    def wikipedia_external_link?(external_link)
      external_link.external_resource == ExternalResources::WIKIPEDIA
    end

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

    def external_link_chain_icon
      tag.svg(
        xmlns: 'http://www.w3.org/2000/svg',
        width: 16,
        height: 16,
        fill: 'currentColor',
        viewBox: '0 0 16 16',
        class: 'b-external-link-icon',
        'aria-hidden': true
      ) do
        safe_join(
          [
            tag.path(
              d: 'M4.715 6.542 3.343 7.914a3 3 0 1 0 4.243 4.243l1.828-1.829A3 3 0 0 0 8.586 5.5L8 6.086a1 ' \
                 '1 0 0 0-.154.199 2 2 0 0 1 .861 3.337L6.88 11.45a2 2 0 1 1-2.83-2.83l.793-.792a4 4 0 0 1-' \
                 '.128-1.287z'
            ),
            tag.path(
              d: 'M6.586 4.672A3 3 0 0 0 7.414 9.5l.775-.776a2 2 0 0 1-.896-3.346L9.12 3.55a2 2 0 1 1 2.83 ' \
                 '2.83l-.793.792c.192.4.3.84.128 1.287l1.372-1.372a3 3 0 1 0-4.243-4.243z'
            )
          ]
        )
      end
    end
  end
end
