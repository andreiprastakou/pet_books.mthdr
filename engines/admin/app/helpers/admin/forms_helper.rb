module Admin
  module FormsHelper
    def admin_reversible_input(old_value:, &)
      content_tag(:div, data: { controller: 'input-changes', old_value: old_value },
                        class: 'b-reversible-input-container') do
        safe_join(
          [
            capture(&),
            content_tag(:div, class: 'form-text b-info', data: { input_changes_target: 'oldValueView' }) do
              safe_join(
                [
                  'was <',
                  content_tag(:span, old_value,
                              data: { name: 'oldValueText', action: 'click->input-changes#resetOldValue' },
                              class: 'b-reset-button b-old-value'),
                  '>'
                ]
              )
            end
          ]
        )
      end
    end

    def admin_reversible_link_input(old_value:, &)
      content_tag(:div, data: { controller: 'input-changes', old_value: old_value },
                        class: 'b-reversible-input-container') do
        safe_join(
          [
            capture(&),
            content_tag(:div, class: 'form-text b-info', data: { input_changes_target: 'oldValueView' }) do
              safe_join(
                [
                  'was <',
                  content_tag(:span, '🔗', data: { action: 'click->input-changes#resetOldValue' },
                                          class: 'b-reset-button b-old-value', title: old_value),
                  '>'
                ]
              )
            end
          ]
        )
      end
    end

    def authors_to_badges_entries(authors)
      authors.map do |author|
        { label: author.fullname, id: author.id }
      end
    end

    def series_to_badges_entries(series)
      series.map do |series|
        { label: series.name, id: series.id }
      end
    end

    def books_to_badges_entries(books)
      books.map do |book|
        {
          label: book_label_for_badges(book),
          id: book.id
        }
      end
    end

    def book_public_lists_to_input_entries(book_public_lists)
      book_public_lists.map do |book_public_list|
        {
          label: book_label_for_badges(book_public_list.book),
          id: book_public_list.id,
          book_id: book_public_list.book_id,
          role: book_public_list.role
        }
      end
    end

    def generic_links_to_input_entries(generic_links)
      generic_links.map do |generic_link|
        {
          id: generic_link.id,
          name: generic_link.name,
          url: generic_link.url
        }
      end
    end
  end
end
